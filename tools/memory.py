class Memory:
    def __init__(self, size, unit = 1):
        if size % unit != 0:
            raise "Memory size not aligned"
        if size == 0:
            self.auto = True
            self.buf = {}
        else:
            self.auto = False
            self.buf = [0] * (size / unit)
        self.size = size
        self.unit = unit
        for i in xrange(0, size / unit):
            self.buf[i] = [ [0] * unit, None ]

    def set(self, addr, bytes, comment = None):
        if ((addr % self.unit != 0) or (len(bytes) % self.unit != 0)) and comment != None:
            raise "Can't set comment for unaligned data"
        elif comment != None:
            if self.auto and not self.buf.has_key(addr / self.unit):
                self.buf[addr / self.unit] = [ {}, None ]
            self.buf[addr / self.unit][1] = comment
        for b in bytes:
            if self.auto and not self.buf.has_key(addr / self.unit):
                self.buf[addr / self.unit] = [ {}, None ]
            self.buf[addr / self.unit][0][addr % self.unit] = b
            addr = addr + 1
        if self.auto and self.size < addr:
            self.size = addr
            if self.size % self.unit != 0:
                self.size += self.unit - self.size % self.unit

    def get(self, addr, len = None):
        if len == None:
            len = self.unit
        bytes = []
        if len == self.unit and addr % self.unit == 0:
            if self.auto and not self.buf.has_key(addr / self.unit):
                comment = None
            else:
                comment = self.buf[addr / self.unit][1]
        else:
            comment = None
        for i in xrange(0, len):
            if self.auto and not self.buf.has_key(addr / self.unit):
                bytes = bytes + [0]
            elif self.auto and not self.buf[addr / self.unit][0].has_key(addr % self.unit):
                bytes = bytes + [0]
            else:
                bytes = bytes + [ self.buf[addr / self.unit][0][addr % self.unit] ]
            addr = addr + 1
        return bytes, comment

    def fill(self, another):
        for i in xrange(0, self.size):
            l = self.get(i, 1)
            if l[1] == None or another.unit > self.unit:
                another.set(i, l[0])
            else:
                another.set(i, l[0], l[1])

    def dump(self):
        for i in xrange(0, self.size, self.unit):
            l = self.get(i)
            if l[1] == None:
                print ("0x%08x: 0x%0" + ("%d" % (self.unit*2)) + "x") % (i, reduce(lambda x,y:(x<<8)|y, l[0][::-1]))
            else:
                print ("0x%08x: 0x%0" + ("%d" % (self.unit*2)) + "x # %s") % (i, reduce(lambda x,y:(x<<8)|y, l[0][::-1]), l[1])
