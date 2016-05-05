#!/usr/bin/env python

import sys
import re

def print_header(f):
    print >>f, "DEPTH = 64;"
    print >>f, "WIDTH = 32;"
    print >>f, "ADDRESS_RADIX = HEX;"
    print >>f, "DATA_RADIX = HEX;"
    print >>f, "CONTENT"
    print >>f, "BEGIN"

def print_footer(f):
    print >>f, "END;"

def main():
    re_sym = re.compile(r"[0-9a-f]*.*<.*>:.*")
    re_asm = re.compile(r"([ 0-9a-f]*):[^0-9a-f]*([0-9a-f]*)[^0-9a-f].*")
    last_code = ""
    if len(sys.argv) != 2:
        print "Usage: %s <output_mif>" % (sys.argv[0])
        sys.exit(-1)
    with open(sys.argv[1], "w") as f:
        print_header(f)
        for l in sys.stdin.readlines():
            if l.strip() == "":
                continue
            if re_sym.match(l) != None:
                continue
            asm = re_asm.match(l)
            if asm != None:
                addr = int(asm.group(1), 16)
                print >>f, "%3X : %s; %% (%03x) %s %%" % (addr/4, asm.group(2), addr, last_code)
                last_code = ""
                continue
            if l[0] == '.':
                continue
            last_code = l[:-1]
        print_footer(f)

if __name__ == "__main__":
    main()
