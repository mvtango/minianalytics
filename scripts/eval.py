#! /usr/bin/env python3
"""
%(prog)s -- tsvfile processor:


USAGE: %(prog)s 'col1_hash=lambda row: hashlib.md5(row["col1"]).hexdigest()'

Add columns to tsv file by applying python lambda functions.

"""
import sys
import os
import re
import csv
import itertools
from collections import OrderedDict
import hashlib

def md5(args, algorithm=hashlib.md5):
    hashval = algorithm()
    for a in args:
        hashval.update(a.encode("utf-8"))
    return hashval.hexdigest()

class OrderedDefaultListDict(OrderedDict): #name according to default
    def __missing__(self, key):
        self[key] = value = [] #change to whatever default you want
        return value

def process(argl) :
    rex = OrderedDict()
    rex = [ (a[0], compile(a[1],__file__,"eval"), a[1])
            for a in
            (v.split("=",1) for v in argl)
          ]
    extrakeys = list(a[0] for a in rex)
    for (c,cf,cs) in rex:
        sys.stderr.write(f"Adding column '{c}': {cs}\n")
    # rex=dict(( a[0] : re.compile(a[1]) (for v in argl)}
    in_file=csv.DictReader(sys.stdin, delimiter="\t")
    out_file=None
    for row in in_file:
        for (n, v, cs) in rex:
            try:
                row[n] = eval(v)(row)
            except Exception as e:
                row[n] = None
                sys.stderr.write(f"\n{row} - while adding {n}: {e}\n")
        if out_file is None:
            keys = list(row.keys())
            for k in extrakeys:
                if not k in keys:
                    keys.append(k)
            sys.stderr.write(f"Columns: {keys}\n")
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

