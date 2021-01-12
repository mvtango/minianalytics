

import sys
import re
import urllib.parse

def process() :
    for line in sys.stdin.readlines():
        if "%0" in line or "%1" in line:
            sys.stdout.write(line)
        else:
            unquoted = urllib.parse.unquote_plus(line)
            sys.stdout.write(unquoted)

def main():
    process()

if __name__=='__main__' :
    main()

