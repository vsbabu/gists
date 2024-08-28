#!/usr/bin/env python3
"""
Scrapes Google Play store package listing for an app and get latest 
comments.
"""
import re
import datetime
import json
import requests

url="https://play.google.com/store/apps/details?id=com.google.android.googlequicksearchbox"

re_message = re.compile('^,([1-5]),null,"(.*?)",\[(\d+),(\d+)\]$')
re_author = re.compile('\["gp:.*?",\["(.*?)",\[')


class FixedList(list):
    """Fixed size list that pushes out values when it grows out of size"""

    def __init__(self, maxlen=4):
        self.maxlen = maxlen

    def append(self, item):
        list.append(self, item)
        if len(self) > self.maxlen:
            self[:1] = []


messages = []
lines = FixedList(4)
r = requests.get(url, stream=True)
is_likes = False  # we should seek 1 line after message instead
keys = "author rating message postdt likes".split()
for line in r.iter_lines():
    line = line.decode("utf-8")
    lines.append(line.strip())
    if is_likes:
        likes = int(line.split(",")[1])
        messages[-1]["likes"] = likes
        is_likes = False
        # TODO: add whether responded to
    is_message = re_message.match(line)
    if is_message:
        msg = dict.fromkeys(keys)
        msg["author"] = re_author.search(lines[-4]).group(1)
        msg["rating"] = int(is_message.group(1))
        msg["message"] = is_message.group(2)
        msg["postdt"] = datetime.datetime.fromtimestamp(int(is_message.group(3)))
        is_likes = True
        messages.append(msg)

print(json.dumps(messages, default=str, indent=4, sort_keys=False))