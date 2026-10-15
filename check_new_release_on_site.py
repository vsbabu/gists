# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "bs4",
#     "requests",
#     "rich",
# ]
# ///
"""
Quick python3 script to check if a new release has been done for some software I use. Software list is
configured in check_new_release_on_site/*.toml. You run this script with the list of software configuration
files as arguments.

Dependencies: BeautifulSoup4

Script gets the web page content from release page and parses it for release list. Takes the latest release
from that.

The list of such software => release information is serialized using pickle. If a new release is
detected which is different from pickled one, the download url is printed out. Pickle file is created
in the directory where you ran the script from and with the name as script file name with a .db extention.
Note that if you run this only for certain toml files, only those are updated in the pickle and existing entries are
untouched.

It is assumed that you download and  install it separately. For convenience, a bash script for installing
changed versions are printed. You can copy-paste and run it.
"""

import logging
import os
import pickle

# re support is provided in lambda in config files
# disable ruff on this unused import
import re  # noqa: F401
import signal
import sys
import tempfile
import textwrap
import tomllib
import traceback
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from threading import Event
from types import FunctionType

import requests
from bs4 import BeautifulSoup
from rich.console import Console
from rich.logging import RichHandler
from rich.table import Table

logging.basicConfig(
    level    =logging.ERROR,
    format   ="%(asctime)s|%(levelname)s|%(message)s",
    datefmt  ="%Y-%m-%d %H:%M:%S",
    handlers = [RichHandler()]
)
log = logging.getLogger("rich")

def resolve_lambda(lambda_str: str) -> FunctionType:
    """Safely evaluates a lambda string expression into a live function."""
    if not isinstance(lambda_str, str):
        return lambda_str
    clean_str = lambda_str.strip()
    if not clean_str.startswith("lambda"):
        raise ValueError(f"String must start with 'lambda', got: {clean_str}")
    # Note: Use eval with caution if parsing untrusted TOML configuration files
    try:
        # evaluate the lambda string in an isolated scope is better; but it won't run
        # lambdas that have regex (re.) library usage
        #func = eval(clean_str, {"__builtins__": None}, {})
        func = eval(clean_str)
        if not callable(func):
            raise TypeError(f"Expression did not return a callable: {lambda_str}")
        return func
    except Exception as e:
        raise ValueError(f"Failed to compile lambda expression: {e}")


@dataclass
class ReleaseSite:
    name: str
    url: str
    extractor: FunctionType
    install_script_template: str = ""
    download_url_template: str = ""

    found_release: str = ""
    download_url: str = ""
    install_script: str = ""
    downloadable: bool = None

    @classmethod
    def from_toml(cls, file_path: str) -> "ReleaseSite":
        with open(file_path, "rb") as f:
            data = tomllib.load(f)
        if "extractor" in data:
            data["extractor"] = resolve_lambda(data["extractor"])
        return cls(**data)

    def get_latest_release(self) -> str:
        r = requests.get(self.url)
        soup = BeautifulSoup(r.content, "html.parser")
        try:
            self.found_release = self.extractor(soup)
        except Exception:
            log.error(f"error parsing latest release -> {soup}" )
            log.error(traceback.format_exc())
            #log.error(inspect.getsource(self.extractor).strip())
            raise
        self.download_url =  self.download_url_template.format(**self.__dict__)
        self.install_script =  textwrap.dedent(self.install_script_template.format(**self.__dict__))
        log.debug(f"Found Latest Release {self.name}")
        return self.found_release

    def __getstate__(self):
        # we need to keep only name and found_release in pickle for next run
        d = {"name": self.name, "found_release": self.found_release}
        return d

def handle_sigint(signum, frame):
    done_event.set()

def check_downloadable(s:ReleaseSite, saved) -> ReleaseSite:
    log.debug(f"Parsing relase page for latest version -> {s.name}")
    s.found_release = "."
    try:
        s.get_latest_release()
        log.debug(f"Got latest version -> {s.found_release}")
    except Exception:
        log.error(f"{s.name} -> error getting latest release")
        log.error(traceback.format_exc())
        return s
    s.downloadable = True
    cache = saved.get(s.name)
    if cache is not None and cache.found_release == s.found_release:
        s.downloadable = False
        log.debug(f"Cached version is same as latest version -> {s.found_release}")
    saved[s.name] = s
    download_url = "[green] ✓ [/green]"
    if s.downloadable:
        download_url = s.download_url
        if s.install_script.strip() != "":
            install_scripts.append(s.install_script)
    s.download_url = download_url
    return s

if __name__ == "__main__":

    if len(sys.argv) > 1:
        install_scripts = []
        dbfile = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), os.path.basename(sys.argv[0]) + ".db")
        log.debug(f"Unpickling -> {dbfile}")
        try:
            with open(dbfile, "rb") as f:
                saved = pickle.load(f)
        except FileNotFoundError:
            saved = {}
            log.debug("No pickle cache found")
    else:
        sys.exit(0)

    console = Console()

    tasks = []
    with console.status("[green]Processing...[/green]", spinner="dots") as status:
        for i,rs in enumerate(sys.argv[1:]):
            log.debug(f"Loading site config from -> {rs}")
            try:
                s = ReleaseSite.from_toml(rs)
            except Exception:
                log.error(f"{rs} -> error loading config file")
                log.error(traceback.format_exc())
                continue
            tasks.append(s)

        done_event = Event()
        signal.signal(signal.SIGINT, handle_sigint)
        status.update("[green]Configured %d tasks[/green]"% (len(tasks)), spinner="dots10")
        with ThreadPoolExecutor(max_workers=4) as pool:
            log.debug("Release url page check: start")
            futures = [pool.submit(check_downloadable, s, saved) for s in tasks]
            status.update("[green]Queued %d tasks[/green]"% (len(tasks)), spinner="dots11")
            for f in futures: #wait for completion of all
                f.result()
            status.update("[green]Found latest versions for %d tasks[/green]"% (len(tasks)), spinner="dots12")
            log.debug("Release url page check: finish")

        with open(dbfile, "wb") as f:
            pickle.dump(saved, f)

        table = Table()
        table.add_column("#", style="dim", width=5, justify="center" )
        table.add_column("Application")
        table.add_column("Version", style="cyan")
        table.add_column("URL", justify="left")
        for i,s in enumerate(tasks):
            if i == 0:
                log.debug(" # | %20s | %-10s | %s |" % ("Name", "Latest", "Download"))
            if s.downloadable and s.install_script.strip() != "":
                log.debug(" %d | %20s | %-10s | %s |" % (i+1, s.name, s.found_release, s.download_url))
            table.add_row(str(i+1), s.name, s.found_release, s.download_url)
        console.print(table)

    if len(install_scripts) > 0:
        shfile = os.path.join(os.environ.get("TMPDIR", tempfile.gettempdir()), os.path.basename(sys.argv[0]) + ".sh")
        with open(shfile, "w", encoding="utf-8") as f:
            f.write("#!/bin/bash\n")
            f.write("CURDIR=`pwd`\n")
            for i,s in enumerate(install_scripts):
                f.write(s)
                f.write("\n")
                log.debug("[%d] wrote install script fragment => " % i)
                log.debug(s)
            f.write("cd $CURDIR\n")
        os.chmod(shfile, 0o755)
        console.print(f"Installation steps are in {shfile}")
