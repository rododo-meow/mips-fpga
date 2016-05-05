#!/usr/bin/env python

import sys

def print_header(f):
    print >>f, "DEPTH = 32;"
    print >>f, "WIDTH = 32;"
    print >>f, "ADDRESS_RADIX = HEX;"
    print >>f, "DATA_RADIX = HEX;"
    print >>f, "CONTENT"
    print >>f, "BEGIN"

def print_footer(f):
    print >>f, "END;"

def main():
    if len(sys.argv) != 3:
        print "Usage: %s <raw_data> <output_mif>" % (sys.argv[0])
        sys.exit(-1)
    with open(sys.argv[1], "rb") as inf:
        with open(sys.argv[2], "w") as outf:
            print_header(outf)
            addr = 0
            while True:
                data = inf.read(4)
                if len(data) == 0:
                    break
                print >>outf, "%3x : %08X; %% (%03X) %%" % (addr/4, (ord(data[0]) << 24) | (ord(data[1]) << 16) | (ord(data[2]) << 8) | ord(data[3]), addr)
                addr = addr + 4
            print_footer(outf)

if __name__ == "__main__":
    main()
