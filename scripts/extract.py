#! /usr/bin/env python3
"""
%(prog)s -- tsvfile processor


USAGE: %(prog)s col1=regexp1 col2=regexp2 col3=regexp3  <TSVIN >TSVOUT

Add columns to tsv file by applying regular expressions to column values.

Inspired by [RegExSerDe](https://github.com/apache/hive/blob/trunk/contrib/src/java/org/apache/hadoop/hive/contrib/serde2/RegexSerDe.java).

"""
import sys
import os
import re
import csv
import itertools
from collections import OrderedDict

def process(argl) :
    rex = OrderedDict()
    rex = { a[0] : re.compile(a[1])
            for a in
            (v.split("=",1) for v in argl)
          }
    extrakeys = list(itertools.chain.from_iterable(( c for c in
                   (  re.findall(r'<([a-z]+)>', p.pattern)
                        for p in rex.values()
                    )
                )))
    sys.stderr.write(f"Matching: {rex}\n")
    sys.stderr.write(f"Adding columns: {extrakeys}\n")
    # rex=dict(( a[0] : re.compile(a[1]) (for v in argl)}
    in_file=csv.DictReader(sys.stdin, delimiter="\t")
    out_file=None
    for row in in_file:
        for (n, v) in rex.items():
            if not n in row.keys():
               pass
            else:
                extracted = v.search(row[n])
                if extracted is not None:
                    row.update(extracted.groupdict())
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

