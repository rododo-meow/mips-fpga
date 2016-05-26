#!/usr/bin/env python

import sys
import re
from memory import Memory

class BadMIF:
    def __init__(self):
        pass

class BadMIFParameter:
    def __init__(self):
        pass

class MifFile:
    def __init__(self, filename):
        self.filename = filename
        self.read()
        self.write_back()

    def read(self):
        try:
            with open(self.filename, "r") as f:
                self.__read_header(f)
                self.__read_content(f)
        except IOError:
            pass

    def init(size, unit):
        self.memory = Memory(size, unit)

    def __read_header(self, f):
        l = f.readline()
        m = re.match(r"^\s*DEPTH\s*=\s*([0-9]*)\s*;\s*$", l)
        if m == None:
            raise BadMIF()
        depth = int(m.group(1))
        l = f.readline()
        m = re.match(r"^\s*WIDTH\s*=\s*([0-9]*)\s*;\s*$", l)
        if m == None:
            raise BadMIF()
        unit = int(m.group(1))
        if unit % 8 != 0:
            raise BadMIFParameter()
        unit = unit / 8
        l = f.readline()
        m = re.match(r"^\s*ADDRESS_RADIX\s*=\s*HEX\s*;\s*$", l)
        if m == None:
            raise BadMIF()
        l = f.readline()
        m = re.match(r"^\s*DATA_RADIX\s*=\s*HEX\s*;\s*$", l)
        if m == None:
            raise BadMIF()
        self.memory = Memory(depth * unit, unit)

    def __read_content(self, f):
        l = f.readline()
        m = re.match(r"^\s*CONTENT\s*$", l)
        if m == None:
            raise BadMIF()
        l = f.readline()
        m = re.match(r"^\s*BEGIN\s*$", l)
        if m == None:
            raise BadMIF()

        re_end = re.compile(r"^\s*END\s*;\s*$")
        re_content = re.compile(r"^\s*([0-9a-fA-F]+)\s*:\s*([0-9a-fA-F]{%d})\s*;\s*(%%(.*)%%)?\s*$" % (self.memory.unit*2))
        l = f.readline()
        while re_end.match(l) == None:
            m = re_content.match(l)
            if m == None:
                raise BadMIF()
            self.memory.set(int(m.group(1),16)*self.memory.unit, map(lambda x: int(x,16), [ m.group(2)[i*2:i*2+2] for i in xrange(0,len(m.group(2))/2) ]), m.group(4))
            l = f.readline()
            if l == "":
                break
        if l == "":
            raise BadMIF()

    def __print_header(self, f):
        print >>f, "DEPTH = %d;" % (self.memory.size / self.memory.unit)
        print >>f, "WIDTH = %d;" % (self.memory.unit * 8)
        print >>f, "ADDRESS_RADIX = HEX;"
        print >>f, "DATA_RADIX = HEX;"

    def __print_content(self, f):
        print >>f, "CONTENT"
        print >>f, "BEGIN"
        for i in xrange(0, self.memory.size, self.memory.unit):
            line = self.memory.get(i)
            if line[1] == None:
                print >>f, "%4X : %s;" % (i / self.memory.unit, reduce(lambda x,y:x+y, map(lambda x:"%02x"%(x), line[0][::-1])))
            else:
                print >>f, "%4X : %s; %% %s %%" % (i / self.memory.unit, reduce(lambda x,y:x+y, map(lambda x:"%02x"%(x), line[0][::-1])), line[1])
        print >>f, "END;"

    def write_back(self):
        try:
            with open("b", "w") as f:
                self.__print_header(f)
                self.__print_content(f)
        except IOError:
            print >>sys.stderr, "Can't open file for write"

def main():
    mif = MifFile("a.mif")

if __name__ == "__main__":
    main()
