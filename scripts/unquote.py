#! /usr/bin/env python3
"""
%(prog)s -- tsvfile processor


USAGE: %(prog)s col1 [col2 ...]

url_unquote columns

"""
import sys
import os
import re
import csv
import itertools
from collections import OrderedDict
import urllib.parse


def process(argl) :
    sys.stderr.write(f"Unqoting columns: {argl}\n")
    in_file=csv.DictReader(sys.stdin, delimiter="\t")
    out_file=None
    safestr = ''.join((chr(a) for a in range(ord(' '),255)))
    for row in in_file:
        for column in argl:
            unquoted = urllib.parse.unquote_plus(row[column])
            row[column] = re.sub("[\x00-\x1f]", lambda a: "%%%02x" % ord(a.group(0)), unquoted)
        if out_file is None:
            keys = list(row.keys())
            out_file=csv.DictWriter(sys.stdout, keys, delimiter="\t")
            out_file.writeheader()
        out_file.writerow(row)

def main():
    if len(sys.argv)<2 :
        print(__doc__ % dict(prog=sys.argv[0]))
    else :
        process(sys.argv[1:])

if __name__=='__main__' :
    main()

