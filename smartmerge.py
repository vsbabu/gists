#!/usr/bin/env python3
"""
Pure python3 implementation to merge two csv files. Useful for getting incremental data
and updating existing large file. 

Arguments:
    Mandatory:
        old file
        new file
    field separator: default is ,. Quoting is not handled.
    key fields: default is first field. If only one field, specify if. If a range of fields, use startindex:endindex format
    input files have no header. If not present, we assume has header.
"""
import sys
import csv

if len(sys.argv) < 3:
    sys.exit(1)
fold=sys.argv[1]
fnew=sys.argv[2]
if len(sys.argv) > 3:
    sep=sys.argv[3]
else:
    sep=","

ksi = 0
kei = None
if len(sys.argv) > 4:
    keys=sys.argv[4].split(":")
    if len(keys) >= 1:
        ksi = int(keys[0])
    if len(keys) >= 2:
        kei = int(keys[1])

hasHeader=True
if len(sys.argv) > 5:
    hasHeader=False

data={}
header=None

def csv2dict(reader):
    for row in reader:
        if kei is not None:
            k = sep.join(row[ksi:kei])
        else:
            k = sep.join(row[ksi])
        data[k] = row

with open(fold) as fin:
    reader=csv.reader(fin, skipinitialspace=True, delimiter=sep)
    if hasHeader:
        header=next(reader,None)
    csv2dict(reader)
with open(fnew) as fin:
    reader=csv.reader(fin, skipinitialspace=True, delimiter=sep)
    if hasHeader:
        header=next(reader,None)
    csv2dict(reader)

if header is not None:
    print(sep.join(header),  end="\n")
for i in sorted(data.keys()):
    print(sep.join(data[i]),  end="\n")

