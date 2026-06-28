# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "bs4",
#     "requests",
# ]
# ///
"""
Quick python3 script to check if a new release has been done for some software I use. Currently, works for
Zen Browser and SQLPage. been

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
from dataclasses import dataclass
from types import FunctionType

import requests
from bs4 import BeautifulSoup


@dataclass
class ReleaseSite:
    name: str
    url: str
    download_url: str
    # fmt: off
    extractor:  FunctionType  # pass a function/lambda to parse html to get the latest version
    # fmt: on
    found_release: str = ""

    def get_latest_release(self) -> str:
        r = requests.get(self.url)
        soup = BeautifulSoup(r.content, "html.parser")
        self.found_release = self.extractor(soup)
        return self.found_release

    def get_download_url(self) -> str:
        return self.download_url.format(self.found_release)

    # remove FunctionType from list of pickled items
    def __getstate__(self):
        d = dict(self.__dict__)
        del d["extractor"]
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
        download_url="https://zen-browser.app/download/ manually {0}",
        # fmt: off
        extractor=lambda x: x.find("section", class_="release-note-item")["id"],  # pyright: ignore # type: ignore
        # fmt: on
    )
    sites["SQLPage"] = ReleaseSite(
        name="SQLPage",
        url="https://github.com/sqlpage/SQLPage/tags",
        download_url="https://github.com/sqlpage/SQLPage/releases/download/{0}/sqlpage-linux.tgz",
        # fmt: off
        extractor=lambda x: x.find("a", class_="Link--primary").text.strip(),  # pyright: ignore # type: ignore
        # fmt: on
    )

    sites["Joplin"] = ReleaseSite(
        name="Joplin",
        url="https://joplinapp.org/help/install/",
        download_url="https://objects.joplinusercontent.com/v{0}/Joplin-{0}.AppImage?source=JoplinWebsite&type=New",
        # fmt: off
        extractor=lambda x: x.find("a", href=re.compile(r".*?AppImage\?source=.*?"))
        .get("href")
        .split("/")[3][1:],  # pyright: ignore # type: ignore
        # fmt: on
    )

    sites["Pragtical"] = ReleaseSite(
        name="Pragtical",
        url="https://github.com/pragtical/pragtical/tags",
        download_url="https://github.com/pragtical/pragtical/releases/download/{0}/pragtical-{0}-linux-x86_64-portable.tar.gz",
        # fmt: off
        extractor=lambda x: x.find("a", class_="Link--primary", string=re.compile(r"""^\s*v\d+\.""")).text.strip(),  # pyright: ignore # type: ignore
        # fmt: on
    )

    sites["Helium"] = ReleaseSite(
        name="Helium",
        url="https://github.com/imputnet/helium-linux/releases",
        download_url="https://github.com/imputnet/helium-linux/releases/download/{0}/helium-bin_{0}-1_amd64.deb",
        # fmt: off
        extractor=lambda x: x.find("a", href="/imputnet/helium-linux/releases/latest").find_previous("a").text.strip() ,  # pyright: ignore # type: ignore
        # fmt: on
    )

    sites["Zellij"] = ReleaseSite(
        name="Zellij",
        url="https://github.com/zellij-org/zellij/releases",
        download_url="https://github.com/zellij-org/zellij/releases/download/{0}/zellij-no-web-x86_64-unknown-linux-musl.tar.gz",
        # fmt: off
        extractor=lambda x: x.find("a", href="/zellij-org/zellij/releases/latest").find_previous("a").text.strip().split()[-1] ,  # pyright: ignore # type: ignore
        # fmt: on
    )

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
        logging.info("%s -> found  %s" % (s.name, s.found_release))
        if downloadable:
            logging.info("\t get %s" % s.get_download_url())

    f = open(dbfile, "wb")
    pickle.dump(sites, f)
    f.close()
