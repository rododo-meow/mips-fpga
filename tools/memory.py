class Memory:
    def __init__(self, size, unit = 1):
        if size % unit != 0:
            raise "Memory size not aligned"
        self.size = size
        self.unit = unit
        self.buf = [0] * (size / unit)
        for i in xrange(0, size / unit):
            self.buf[i] = [ [0] * unit, None ]

    def set(self, addr, bytes, comment = None):
        if ((addr % self.unit != 0) or (len(bytes) % self.unit != 0)) and comment != None:
            raise "Can't set comment for unaligned data"
        elif comment != None:
            for i in xrange(addr / self.unit, (addr + len(bytes)) / self.unit):
                self.buf[i][1] = comment
        for b in bytes:
            self.buf[addr / self.unit][0][self.unit - addr % self.unit - 1] = b
            addr = addr + 1

    def get(self, addr, len = None):
        if len == None:
            len = self.unit
        bytes = []
        comment = self.buf[addr / self.unit][1]
        for i in xrange(0, len):
            bytes = bytes + [ self.buf[addr / self.unit][0][addr % self.unit] ]
            addr = addr + 1
        return bytes, comment

    def dump(self):
        for i in xrange(0, self.size):
            if self.buf[i / self.unit][1] == None:
                print ("0x%08x: 0x%02x") % (i, self.buf[i / self.unit][0][i % self.unit])
            else:
                print ("0x%08x: 0x%02x # %s") % (i, self.buf[i / self.unit][0][i % self.unit], self.buf[i / self.unit][1])
