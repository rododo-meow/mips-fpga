#!/usr/bin/env python

import re
import sys
from memory import Memory

def _Assembler__bind(func, arg0):
    def _func(*args):
        return func(arg0, *args)
    return _func

def _Assembler__resolvMipsReg(name):
    if name == "ra":
        return 31
    elif int(name) > 31 or int(name) < 0:
        raise BaseException("Invalid MIPS register $%s" % (name))
    else:
        return int(name)

def _Assembler__make_reloc(type, addr, value):
    return [ [ type, addr, value ] ]

def _Assembler__make_mips_ins(type, *args):
    if type == "R":
        if len(args) != 6 or \
            args[0] > 0x3f or args[0] < 0 or \
            args[1] > 0x1f or args[1] < 0 or \
            args[2] > 0x1f or args[2] < 0 or \
            args[3] > 0x1f or args[3] < 0 or \
            args[4] > 0x1f or args[4] < 0 or \
            args[5] > 0x3f or args[5] < 0:
            raise BaseException("Wrong parameter to generate MIPS R instruction")
        ins = (args[0] << 26) | (args[1] << 21) | (args[2] << 16) | (args[3] << 11) | (args[4] << 6) | args[5]
        return [ ins & 0xff, (ins >> 8) & 0xff, (ins >> 16) & 0xff, (ins >> 24) & 0xff ]
    elif type == "I":
        if len(args) != 4 or \
            args[0] > 0x3f or args[0] < 0 or \
            args[1] > 0x1f or args[1] < 0 or \
            args[2] > 0x1f or args[2] < 0 or \
            args[3] > 0xffff or args[3] < 0:
            raise BaseException("Wrong parameter to generate MIPS R instruction")
        ins = (args[0] << 26) | (args[1] << 21) | (args[2] << 16) | args[3] << 11
        return [ ins & 0xff, (ins >> 8) & 0xff, (ins >> 16) & 0xff, (ins >> 24) & 0xff ]
    elif type == "J":
        if len(args) != 2 or \
            args[0] > 0x3f or args[0] < 0 or \
            args[1] > 0x3ffffff or args[1] < 0:
            raise BaseException("Wrong parameter to generate MIPS R instruction")
        ins = (args[0] << 26) | args[1] << 21
        return [ ins & 0xff, (ins >> 8) & 0xff, (ins >> 16) & 0xff, (ins >> 24) & 0xff ]
    else:
        raise BaseException("Unknown MIPS instruction type %s" % (type))

def _Assembler__cut_tail_newline(l):
    while l[-1] == '\r' or l[-1] == '\n':
        l = l[:-1]
    return l

def myint(s):
    if s[0:2] == "0x" or s[0:2] == "0X":
        return int(s, 16)
    else:
        return int(s)

class Assembler:
    def __init__(self):
        self.re_label = re.compile(r"^\s*([_a-zA-Z][_0-9a-zA-Z]*)\s*:(.*)")
        self.ins = []
        self.ins += self.__make("mips", "R", "Add")
        self.ins += self.__make("mips", "R", "Sub")
        self.ins += self.__make("mips", "R", "And")
        self.ins += self.__make("mips", "R", "Or")
        self.ins += self.__make("mips", "R", "Xor")
        self.ins += self.__make("mips", "S", "Sll")
        self.ins += self.__make("mips", "S", "Srl")
        self.ins += self.__make("mips", "S", "Sra")
        self.ins += self.__make("mips", "Jr", "Jr")
        self.ins += self.__make("mips", "I", "Addi")
        self.ins += self.__make("mips", "I", "Andi")
        self.ins += self.__make("mips", "I", "Ori")
        self.ins += self.__make("mips", "I", "Xori")
        self.ins += self.__make("mips", "M", "Lw")
        self.ins += self.__make("mips", "M", "Sw")
        self.ins += self.__make("mips", "I", "Beq")
        self.ins += self.__make("mips", "I", "Bne")
        self.ins += self.__make("mips", "L", "Lui")
        self.ins += self.__make("mips", "J", "J")
        self.ins += self.__make("mips", "J", "Jal")
        self.ins += self.__make("asm", "0", "Text")
        self.ins += self.__make("asm", "I", "Org")
        self.ins += self.__make("asm", "0", "Data")
        self.ins += self.__make("asm", "E", "Word")
        self.ins += self.__make("asm", "Null", "Null")
        self.instmem = Memory(0, 4)
        self.datamem = Memory(0, 4)
        self.label = {}
        self.now = 0
        self.reloc = []
        self.mode = 0

    def __make(self, isa, type, name):
        return [ [ Assembler.__dict__["_Assembler__" + isa + "_generate" + type](name.lower()), Assembler.__dict__["_Assembler__" + isa + "_resolv" + type](__bind(Assembler.__dict__["_Assembler__" + isa + "_Issue" + name], self)) ] ]

    def compile(self, filename):
        with open(filename, "r") as f:
            for l in f.readlines():
                if self.re_label.match(l):
                    m = self.re_label.match(l)
                    self.label[m.group(1)] = self.now
                if l.strip() == "":
                    continue
                succ = False
                for ins in self.ins:
                    if ins[0].match(l) != None:
                        ins[1](ins[0].match(l))
                        succ = True
                        break
                if not succ:
                    raise BaseException("No such instruction %s" % (l))

    def relocate(self):
        for r in self.reloc:
            if r[0] == "MIPS_IMM":
                imm = eval(r[2], self.label)
                if imm > 0xffff:
                    print >>sys.stderr, "Warning: imm '%s' overflow" % (r[2])
                self.instmem.set(r[1], [ imm & 0xff, (imm >> 8) & 0xff ])
            elif r[0] == "MIPS_OFF":
                target = eval(r[2], self.label)
                target -= (r[1] + 4)
                if target & 0x3 != 0:
                    print >>sys.stderr, "Error: pc offset '%s' not aligned" % (r[2])
                    sys.exit(1)
                target = target >> 2
                if target > 0x7fff or target < -0x8000:
                    print >>sys.stderr, "Error: pc offset '%s' overflow" %(r[2])
                    sys.exit(1)
                self.instmem.set(r[1], [ target & 0xff, (target >> 8) & 0xff ])
            elif r[0] == "MIPS_ADDR":
                target = eval(r[2], self.label)
                if target & 0x3 != 0:
                    print >>sys.stderr, "Error: direct jump to '%s' not aligned" % (r[2])
                    sys.exit(1)
                target = target >> 2
                if (target >> 28) & 0xf != (r[1] >> 28) & 0xf:
                    print >>sys.stderr, "Error: direct jump to '%s' overflow" % (r[2])
                    sys.exit(1)
                self.instmem.set(r[1], [ target & 0xff, (target >> 8) & 0xff, self.instmem.get(r[1], 1)[0][0] & 0xc0 | ((target >> 16) & 0x2f) ])

    def __mips_generateR(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s*\$([0-9]+|ra)\s*,\s*\$([0-9]+|ra)*\s*,\s*\$([0-9]+|ra)\s*(#.*)?$")
    def __mips_resolvR(func):
        return lambda match: func(__resolvMipsReg(match.group(1)), __resolvMipsReg(match.group(2)), __resolvMipsReg(match.group(3)), __cut_tail_newline(match.group(0)))
    def __mips_generateS(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s*\$([0-9]+|ra)\s*,\s*\$([0-9]+|ra)*\s*,\s*([0-9]+)\s*(#.*)?$")
    def __mips_resolvS(func):
        return lambda match: func(__resolvMipsReg(match.group(1)), __resolvMipsReg(match.group(2)), myint(match.group(3)), __cut_tail_newline(match.group(0)))
    def __mips_generateJr(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s+\$([0-9]+|ra)\s*(#.*)?$")
    def __mips_resolvJr(func):
        return lambda match: func(__resolvMipsReg(match.group(1)), __cut_tail_newline(match.group(0)))
    def __mips_generateI(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s+\$([0-9]+|ra)\s*,\s*\$([0-9]+|ra)*\s*,\s*([^#\r\n]+)\s*(#.*)?$")
    def __mips_resolvI(func):
        return lambda match: func(__resolvMipsReg(match.group(1)), __resolvMipsReg(match.group(2)), match.group(3), __cut_tail_newline(match.group(0)))
    def __mips_generateM(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s*\$([0-9]+|ra)\s*,\s*([^#\r\n]+)?\s*\(\$([0-9]+|ra)\)*\s*(#.*)?$")
    def __mips_resolvM(func):
        return lambda match: func(__resolvMipsReg(match.group(1)), match.group(2), __resolvMipsReg(match.group(3)), __cut_tail_newline(match.group(0)))
    def __mips_generateL(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s*\$([0-9]+|ra)\s*,\s*([^#\r\n]+)\s*(#.*)?$")
    def __mips_resolvL(func):
        return lambda match: func(__resolvMipsReg(match.group(1)), match.group(2), __cut_tail_newline(match.group(0)))
    def __mips_generateJ(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*" + name + r"\s+([^#\r\n]+)\s*(#.*)?$")
    def __mips_resolvJ(func):
        return lambda match: func(match.group(1), __cut_tail_newline(match.group(0)))

    def __mips_IssueAdd(self, rd, rs, rt, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, rs, rt, rd, 0, 0x20), comment)
        self.now += 4

    def __mips_IssueSub(self, rd, rs, rt, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, rs, rt, rd, 0, 0x22), comment)
        self.now += 4

    def __mips_IssueAnd(self, rd, rs, rt, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, rs, rt, rd, 0, 0x24), comment)
        self.now += 4

    def __mips_IssueOr(self, rd, rs, rt, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, rs, rt, rd, 0, 0x25), comment)
        self.now += 4

    def __mips_IssueXor(self, rd, rs, rt, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, rs, rt, rd, 0, 0x26), comment)
        self.now += 4

    def __mips_IssueSll(self, rd, rt, sa, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, rt, rd, sa, 0x00), comment)
        self.now += 4

    def __mips_IssueSrl(self, rd, rt, sa, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, rt, rd, sa, 0x02), comment)
        self.now += 4

    def __mips_IssueSra(self, rd, rt, sa, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, rt, rd, sa, 0x03), comment)
        self.now += 4

    def __mips_IssueJr(self, rs, comment):
        self.instmem.set(self.now, __make_mips_ins("R", 0, rs, 0, 0, 0, 0x08), comment)
        self.now += 4
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, 0, 0, 0, 0))
        self.now += 4

    def __mips_IssueAddi(self, rt, rs, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x08, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueAndi(self, rt, rs, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x0c, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueOri(self, rt, rs, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x0d, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueXori(self, rt, rs, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x0e, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueLw(self, rt, imm, rs, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x23, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueSw(self, rt, imm, rs, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x2b, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueBeq(self, rs, rt, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x04, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_OFF", self.now, imm)
        self.now += 4
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, 0, 0, 0, 0))
        self.now += 4

    def __mips_IssueBne(self, rs, rt, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x05, rs, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_OFF", self.now, imm)
        self.now += 4
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, 0, 0, 0, 0))
        self.now += 4

    def __mips_IssueLui(self, rt, imm, comment):
        self.instmem.set(self.now, __make_mips_ins("I", 0x0f, 0, rt, 0), comment)
        self.reloc += __make_reloc("MIPS_IMM", self.now, imm)
        self.now += 4

    def __mips_IssueJ(self, addr, comment):
        self.instmem.set(self.now, __make_mips_ins("J", 0x02, 0), comment)
        self.reloc += __make_reloc("MIPS_ADDR", self.now, addr)
        self.now += 4
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, 0, 0, 0, 0))
        self.now += 4

    def __mips_IssueJal(self, addr, comment):
        self.instmem.set(self.now, __make_mips_ins("J", 0x03, 0), comment)
        self.reloc += __make_reloc("MIPS_ADDR", self.now, addr)
        self.now += 4
        self.instmem.set(self.now, __make_mips_ins("R", 0, 0, 0, 0, 0, 0))
        self.now += 4

    def __asm_generate0(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*\." + name + r"\s+(#.*)?$")
    def __asm_resolv0(func):
        return lambda match: func()
    def __asm_generateI(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*\." + name + r"\s+([0-9]+|0[xX][0-9a-fA-F]+)\s+(#.*)?$")
    def __asm_resolvI(func):
        return lambda match: func(myint(match.group(1)))
    def __asm_generateE(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*\." + name + r"\s+([^#\r\n]+)\s+(#.*)?$")
    def __asm_resolvE(func):
        return lambda match: func(match.group(1))
    def __asm_generateNull(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*(#.*)?$")
    def __asm_resolvNull(func):
        return lambda match: func()

    def __asm_IssueText(self):
        pass
    def __asm_IssueData(self):
        pass
    def __asm_IssueOrg(self, now):
        self.now = now
    def __asm_IssueWord(self, data):
        self.reloc += __make_reloc("WORD", self.now, data)
        self.now += 4
    def __asm_IssueNull(self):
        pass

__all__ = []

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print >>sys.stderr, "Usage: %s <mips.S>" % (sys.argv[0])
        sys.exit(1)
    assembler = Assembler()
    assembler.compile(sys.argv[1])
    assembler.relocate()
    assembler.instmem.dump()
