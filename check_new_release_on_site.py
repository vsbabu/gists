# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "bs4",
#     "requests",
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

import os
import sys
import re
import pickle
import logging
import traceback
import textwrap
import importlib
import tomllib
from types import FunctionType
from dataclasses import dataclass, field
import requests
from bs4 import BeautifulSoup

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
        except Exception as e:
            logging.error("error parsing latest release -> %s" % soup )
            logging.error(traceback.format_exc())
            #logging.error(inspect.getsource(self.extractor).strip())
            raise
        self.download_url =  self.download_url_template.format(**self.__dict__)
        self.install_script =  textwrap.dedent(self.install_script_template.format(**self.__dict__))
        return self.found_release

    def __getstate__(self):
        # we need to keep only name and found_release in pickle for next run
        d = dict(name = self.name, found_release = self.found_release)
        return d

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    if len(sys.argv) > 1:
        install_scripts = []
        dbfile = os.path.basename(sys.argv[0]) + ".db"
        logging.debug("Unpickling -> %s" % dbfile)
        try:
            f = open(dbfile, "rb")
            saved = pickle.load(f)
            f.close()
        except FileNotFoundError:
            saved = dict()
            logging.debug("No pickle cache found")

    for i,rs in enumerate(sys.argv[1:]):
        logging.debug("Loading site config from -> %s" % rs)
        try:
            s = ReleaseSite.from_toml(rs)
        except Exception as e:
            logging.error("%s -> error loading config file" % rs)
            logging.error(traceback.format_exc())
            continue
        logging.debug("Parsing relase page for latest version -> %s" % s.name)
        try:
            s.get_latest_release()
        except Exception as e:
            logging.error("%s -> error getting latest release" % s.name)
            logging.error(traceback.format_exc())
            continue
        downloadable = True
        cache = saved.get(s.name)
        if cache is not None and cache.found_release == s.found_release:
            downloadable = False
        saved[s.name] = s
        download_url = "\033[32m\u2713\033[0m" #default is a "tick" to indicate no download needed
        if downloadable:
            download_url = s.download_url
            if s.install_script.strip() != "":
                install_scripts.append(s.install_script)
        logging.info("| %d | %20s | %-10s | %s" % (i+1, s.name, s.found_release, download_url))

    if len(sys.argv) > 1:
        f = open(dbfile, "wb")
        pickle.dump(saved, f)
        f.close()

        if len(install_scripts) > 0:
            print("\n")
            print("============================================")
            print("Installation script that can be run is below")
            print("============================================")
            print("CURDIR=`pwd`")
            for s in install_scripts:
                print(s, end="")
            print("\ncd $CURDIR")
