#!/usr/bin/env python

import sys
from assembler import Assembler
from mifutil import MifFile

def main():
    if len(sys.argv) < 6:
        print >>sys.stderr, "Usage: %s <instmem.mif> <instmem_size in byte> <datamem.mif> <datamem_size in byte> <xxx.S> [xxx.S] ..." % (sys.argv[0])
        sys.exit(1)
    if sys.argv[1] != '-':
        instmif = MifFile(sys.argv[1])
        instmif.init(int(sys.argv[2]), 1)
    else:
        instmif = None
    if sys.argv[3] != '-':
        datamif = MifFile(sys.argv[3])
        datamif.init(int(sys.argv[4]), 4)
    else:
        datamif = None
    assembler = Assembler()
    for filename in sys.argv[5:]:
        assembler.compile(filename)
    assembler.relocate()
    if instmif != None:
        assembler.instmem.fill(instmif.memory)
        instmif.write_back()
    if datamif != None:
        assembler.datamem.fill(datamif.memory)
        datamif.write_back()

if __name__ == "__main__":
    main()
