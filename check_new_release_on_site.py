# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "bs4",
#     "requests",
# ]
# ///
"""
Quick python3 script to check if a new release has been done for some software I use. Currently, works for
Zen Browser and SQLPage and some more that I use.

Dependencies: BeautifulSoup4

Script gets the web page content from release page and parses it for release list. Takes the latest release
from that.

The list of such software => release information is serialized using pickle. If a new release is
detected which is different from pickled one, the download url is printed out. Pickle file is created
from where you ran the script from and with the name as script file name with a .db extention.

It is assumed that you download and  install it separately. Yes, we can automate the --version check
and download for those, but I would rather manually download and install after going over release notes.
"""

import logging
import os
import pickle
import re
import sys
import traceback
import textwrap
from dataclasses import dataclass
from types import FunctionType

import requests
from bs4 import BeautifulSoup


@dataclass
class ReleaseSite:
    name: str
    url: str
    # fmt: off
    extractor:  FunctionType  # pass a function/lambda to parse html to get the latest version
    # fmt: on
    install_script_template: str = ""
    download_url_template: str = ""

    #following are computed on call of get_latest_release
    found_release: str = ""
    download_url: str = ""
    install_script: str = ""

    def get_latest_release(self) -> str:
        r = requests.get(self.url)
        soup = BeautifulSoup(r.content, "html.parser")
        self.found_release = self.extractor(soup)
        self.download_url =  self.download_url_template.format(**self.__dict__)
        self.install_script =  textwrap.dedent(self.install_script_template.format(**self.__dict__))
        return self.found_release

    def __getstate__(self):
        # we need to keep only name and found_release in pickle for next run
        d = dict(name = self.name, found_release = self.found_release)
        return d


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    sites: dict[str, ReleaseSite] = dict()
    dbfile = os.path.basename(sys.argv[0]) + ".db"
    try:
        f = open(dbfile, "rb")
        saved = pickle.load(f)
        f.close()
    except FileNotFoundError:
        saved = dict()

    sites["Zen-browser"] = ReleaseSite(
        name="Zen-browser",
        url="https://zen-browser.app/release-notes/",
        download_url_template="https://zen-browser.app/download/ (manual)",
        # fmt: off
        extractor=lambda x: x.find("section", class_="release-note-item")["id"],  # pyright: ignore # type: ignore
        # fmt: on
    )
    sites["SQLPage"] = ReleaseSite(
        name="SQLPage",
        url="https://github.com/sqlpage/SQLPage/tags",
        download_url_template="https://github.com/sqlpage/SQLPage/releases/download/{found_release}/sqlpage-linux.tgz",
        # fmt: off
        extractor=lambda x: x.find("a", class_="Link--primary").text.strip(),  # pyright: ignore # type: ignore
        # fmt: on
        install_script_template = """
        cd /tmp/
        rm -f sqlpage-linux.tgz
        wget --timeout=10 --tries=2  {download_url}
        cd ~/.local/bin/
        tar -xvzf /tmp/sqlpage-linux.tgz
        """
    )
    sites["Helium"] = ReleaseSite(
        name="Helium",
        url="https://github.com/imputnet/helium-linux/releases",
        download_url_template="https://github.com/imputnet/helium-linux/releases/download/{found_release}/helium-bin_{found_release}-1_amd64.deb",
        # fmt: off
        extractor=lambda x: x.find("a", href="/imputnet/helium-linux/releases/latest").find_previous("a").text.strip() ,  # pyright: ignore # type: ignore
        # fmt: on
        install_script_template = """
        cd /tmp/
        rm -f helium-bin_{found_release}-1_amd64.deb*
        wget --timeout=10 --tries=2  {download_url}
        sudo dpkg -i helium-bin_{found_release}-1_amd64.deb
        """
    )
    sites["Herdr"] = ReleaseSite(
        name="Herdr",
        url="https://github.com/herdrdev/herdr/releases",
        download_url_template="https://github.com/herdrdev/herdr/releases/download/{found_release}/herdr-linux-x86_64",
        # fmt: off
        extractor=lambda x: x.find("a", href="/herdrdev/herdr/releases/latest").find_previous("a").text.strip().split()[-1] ,  # pyright: ignore # type: ignore
        # fmt: on
        install_script_template = """
        cd /tmp/
        rm -f herdr-linux-x86_64
        wget --timeout=10 --tries=2  {download_url}
        cd ~/.local/bin/
        rm herdr
        mv /tmp/herdr-linux-x86_64 herdr
        chmod +x herdr
        """
    )
    sites["px0"] = ReleaseSite(
        name="px0",
        url="https://github.com/px0-ai/px0/releases",
        download_url_template="https://github.com/px0-ai/px0/releases/download/v{found_release}/px0-{found_release}-linux-amd64",
        # fmt: off
        extractor=lambda x: x.find("a", href="/px0-ai/px0/releases/latest").find_previous("a").text.strip().split()[-1][1:] ,  # pyright: ignore # type: ignore
        # fmt: on}
        install_script_template = """
        cd /tmp/
        rm -f px0-{found_release}-linux-amd64
        wget --timeout=10 --tries=2  {download_url}
        cd ~/.local/bin/
        mv /tmp/px0-{found_release}-linux-amd64 px0
        chmod +x px0
        """
    )

    install_scripts = []
    for k in sites.keys():
        s = sites.get(k)  # pyright: ignore[]
        # fmt: off
        if s is None:  # this won't happen, but pyright keeps raising warnings further down otherwise
            continue
        # fmt: on
        try:
            s.get_latest_release()
        except Exception:
            logging.error("%s -> error getting latest release" % s.name)
            logging.error(traceback.format_exc())
            continue
        downloadable = True
        cache = saved.get(s.name)
        if cache is not None and cache.found_release == s.found_release:
            downloadable = False
        download_url = "\033[32m\u2713\033[0m"
        if downloadable:
            download_url = s.download_url
            install_scripts.append(s.install_script)
        logging.info(" %20s | %-10s | %s" % (s.name, s.found_release, download_url))

    f = open(dbfile, "wb")
    pickle.dump(sites, f)
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

###  unused software; you need to add download_and_install_script_template
#    sites["Joplin"] = ReleaseSite(
#        name="Joplin",
#        url="https://joplinapp.org/help/install/",
#        download_url_template="https://objects.joplinusercontent.com/v{found_release}/Joplin-{found_release}.AppImage?source=JoplinWebsite&type=New",
#        # fmt: off
#        extractor=lambda x: x.find("a", href=re.compile(r".*?AppImage\?source=.*?")).get("href").split("/")[3][1:],  # pyright: ignore # type: ignore
#        # fmt: on
#    )
#
#    sites["Pragtical"] = ReleaseSite(
#        name="Pragtical",
#        url="https://github.com/pragtical/pragtical/tags",
#        download_url_template="https://github.com/pragtical/pragtical/releases/download/{found_release}/pragtical-{found_release}-linux-x86_64-portable.tar.gz",
#        # fmt: off
#        extractor=lambda x: x.find("a", class_="Link--primary", string=re.compile(r"""^\s*v\d+\.""")).text.strip(),  # pyright: ignore # type: ignore
#        # fmt: on
#    )
#
#    sites["Zellij"] = ReleaseSite(
#        name="Zellij",
#        url="https://github.com/zellij-org/zellij/releases",
#        download_url_template="https://github.com/zellij-org/zellij/releases/download/{found_release}/zellij-no-web-x86_64-unknown-linux-musl.tar.gz",
#        # fmt: off
#        extractor=lambda x: x.find("a", href="/zellij-org/zellij/releases/latest").find_previous("a").text.strip().split()[-1] ,  # pyright: ignore # type: ignore
#        # fmt: on
#    )
