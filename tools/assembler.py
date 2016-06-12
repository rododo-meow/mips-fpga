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

def _Assembler__make_mips_ins(type, *args):
    if type == "R":
        if len(args) != 6 or \
            args[0] > 0x3f or args[0] < 0 or \
            args[1] > 0x1f or args[1] < 0 or \
            args[2] > 0x1f or args[2] < 0 or \
            args[3] > 0x1f or args[3] < 0 or \
            args[4] > 0x1f or args[4] < 0 or \
            args[5] > 0x3f or args[5] < 0:
            raise BaseException("Wrong parameter to generate MIPS instruction")
        ins = (args[0] << 26) | (args[1] << 21) | (args[2] << 16) | (args[3] << 11) | (args[4] << 6) | args[5]
        return [ ins & 0xff, (ins >> 8) & 0xff, (ins >> 16) & 0xff, (ins >> 24) & 0xff ]
    elif type == "I":
        if len(args) != 4 or \
            args[0] > 0x3f or args[0] < 0 or \
            args[1] > 0x1f or args[1] < 0 or \
            args[2] > 0x1f or args[2] < 0 or \
            args[3] > 0xffff or args[3] < 0:
            raise BaseException("Wrong parameter to generate MIPS instruction")
        ins = (args[0] << 26) | (args[1] << 21) | (args[2] << 16) | args[3] << 11
        return [ ins & 0xff, (ins >> 8) & 0xff, (ins >> 16) & 0xff, (ins >> 24) & 0xff ]
    elif type == "J":
        if len(args) != 2 or \
            args[0] > 0x3f or args[0] < 0 or \
            args[1] > 0x3ffffff or args[1] < 0:
            raise BaseException("Wrong parameter to generate MIPS instruction")
        ins = (args[0] << 26) | args[1] << 21
        return [ ins & 0xff, (ins >> 8) & 0xff, (ins >> 16) & 0xff, (ins >> 24) & 0xff ]
    else:
        raise BaseException("Unknown MIPS instruction type %s" % (type))

def _Assembler__cut_tail_newline(l):
    while l[-1] == '\r' or l[-1] == '\n':
        l = l[:-1]
    return l

def _Assembler__applyTemplate(templates, s):
    while True:
        converge = True
        for t in templates:
            tmp = s.replace("%%" + t, templates[t])
            if tmp != s:
                converge = False
            s = tmp
        if converge:
            break
    return s

_Assembler__y86Temp = {
    "ID": r"[_a-zA-Z][_0-9a-zA-Z]*",
    "REG": r"%(?:eax|ebx|ecx|edx|esi|edi|esp|ebp)",
    "COMMENT": r"(?:#.*)",
    "IMM": r"(?:.+)",
    "COND": r"(?:le|e|l|ne|ge|g)"
}

_Assembler__y86reg = {
    "%eax": 0,
    "%ecx": 1,
    "%edx": 2,
    "%ebx": 3,
    "%esp": 4,
    "%ebp": 5,
    "%esi": 6,
    "%edi": 7
}
def _Assembler__resolvY86Reg(reg):
    return _Assembler__y86reg[reg]

_Assembler__y86cond = {
    "le": 1,
    "l": 2,
    "e": 3,
    "ne": 4,
    "ge": 5,
    "g": 6
}
def _Assembler__resolvY86Cond(cond):
    return _Assembler__y86cond[cond]

def _Assembler__make_y86_ins(type, *args):
    if type == "1":
        if len(args) != 1 or \
            args[0] > 0xff or args[0] < 0:
            raise BaseException("Wrong parameter to generate Y86 instruction")
        return [ args[0] ]
    elif type == "2":
        if len(args) != 3 or \
            args[0] > 0xff or args[0] < 0 or \
            args[1] > 0xf or args[1] < 0 or \
            args[2] > 0xf or args[2] < 0:
            raise BaseException("Wrong parameter to generate Y86 instruction")
        return [ args[0], (args[1] << 4) | args[2] ]
    elif type == "5":
        if len(args) != 2 or \
            args[0] > 0xff or args[0] < 0 or \
            args[1] > 0xffffffff or args[1] < 0:
            raise BaseException("Wrong parameter to generate Y86 instruction")
        return [ args[0], args[1] & 0xff, (args[1] >> 8) & 0xff, (args[1] >> 16) & 0xff, (args[1] >> 24) & 0xff ]
    elif type == "6":
        if len(args) != 4 or \
            args[0] > 0xff or args[0] < 0 or \
            args[1] > 0xf or args[1] < 0 or \
            args[2] > 0xf or args[2] < 0 or \
            args[3] > 0xffffffff or args[3] < 0:
            raise BaseException("Wrong parameter to generate Y86 instruction")
        return [ args[0], (args[1] << 4) | args[2], args[3] & 0xff, (args[3] >> 8) & 0xff, (args[3] >> 16) & 0xff, (args[3] >> 24) & 0xff ]
    else:
        raise BaseException("Unknown Y86 instruction type %s" % (type))

def myint(s):
    if s[0:2] == "0x" or s[0:2] == "0X":
        return int(s, 16)
    else:
        return int(s)

class Assembler:
    def __init__(self):
        self.re_label = re.compile(r"^\s*([_a-zA-Z][_0-9a-zA-Z]*)\s*:(.*)")
        self.mips_ins = []
        self.y86_ins = []
        self.asm_ins = []
        self.mips_ins += self.__make("mips", "R", "Add")
        self.mips_ins += self.__make("mips", "R", "Sub")
        self.mips_ins += self.__make("mips", "R", "And")
        self.mips_ins += self.__make("mips", "R", "Or")
        self.mips_ins += self.__make("mips", "R", "Xor")
        self.mips_ins += self.__make("mips", "S", "Sll")
        self.mips_ins += self.__make("mips", "S", "Srl")
        self.mips_ins += self.__make("mips", "S", "Sra")
        self.mips_ins += self.__make("mips", "R", "Srlv")
        self.mips_ins += self.__make("mips", "Jr", "Jr")
        self.mips_ins += self.__make("mips", "I", "Addi")
        self.mips_ins += self.__make("mips", "I", "Andi")
        self.mips_ins += self.__make("mips", "I", "Ori")
        self.mips_ins += self.__make("mips", "I", "Xori")
        self.mips_ins += self.__make("mips", "M", "Lw")
        self.mips_ins += self.__make("mips", "M", "Sw")
        self.mips_ins += self.__make("mips", "I", "Beq")
        self.mips_ins += self.__make("mips", "I", "Bne")
        self.mips_ins += self.__make("mips", "L", "Lui")
        self.mips_ins += self.__make("mips", "J", "J")
        self.mips_ins += self.__make("mips", "J", "Jal")
        self.mips_ins += self.__make("mips", "J", "JY86")
        self.y86_ins += self.__make("y86", "N", "Halt")
        self.y86_ins += self.__make("y86", "N", "Nop")
        self.y86_ins += self.__make("y86", "RR", "Rrmovl")
        self.y86_ins += self.__make("y86", "IR", "Irmovl")
        self.y86_ins += self.__make("y86", "RIR", "Rmmovl")
        self.y86_ins += self.__make("y86", "IRR", "Mrmovl")
        self.y86_ins += self.__make("y86", "RR", "Addl")
        self.y86_ins += self.__make("y86", "RR", "Subl")
        self.y86_ins += self.__make("y86", "RR", "Andl")
        self.y86_ins += self.__make("y86", "RR", "Xorl")
        self.y86_ins += self.__make("y86", "RR", "Orl")
        self.y86_ins += self.__make("y86", "I", "Jmp")
        self.y86_ins += self.__make("y86", "IC", "J")
        self.y86_ins += self.__make("y86", "RRC", "Cmov")
        self.y86_ins += self.__make("y86", "I", "Call")
        self.y86_ins += self.__make("y86", "N", "Ret")
        self.y86_ins += self.__make("y86", "R", "Pushl")
        self.y86_ins += self.__make("y86", "R", "Popl")
        self.y86_ins += self.__make("y86", "I", "JMIPS")
        self.y86_ins += self.__make("y86", "RI", "Cmpi")
        self.y86_ins += self.__make("y86", "RR", "Cmpl")
        self.y86_ins += self.__make("y86", "IR", "Iaddl")
        self.y86_ins += self.__make("y86", "IR", "Isubl")
        self.y86_ins += self.__make("y86", "IR", "Iorl")
        self.y86_ins += self.__make("y86", "RI", "Slli")
        self.asm_ins += self.__make("asm", "0", "Text")
        self.asm_ins += self.__make("asm", "I", "Org")
        self.asm_ins += self.__make("asm", "0", "Data")
        self.asm_ins += self.__make("asm", "E", "Word")
        self.asm_ins += self.__make("asm", "Null", "Null")
        self.asm_ins += self.__make("asm", "0", "MIPS")
        self.asm_ins += self.__make("asm", "0", "Y86")
        self.asm_ins += self.__make("asm", "Define", "Define")
        self.instmem = Memory(0, 1)
        self.datamem = Memory(0, 1)
        self.label = {}
        self.inst_now = 0
        self.data_now = 0
        self.reloc = []
        self.mode = "MIPS"
        self.sect = "text"
        self.defines = {}
        self.globals = {}
        self.exports = []
        self.externs = []

    def __make(self, isa, type, name):
        return [ [ Assembler.__dict__["_Assembler__" + isa + "_generate" + type](name.lower()), Assembler.__dict__["_Assembler__" + isa + "_resolv" + type](__bind(Assembler.__dict__["_Assembler__" + isa + "_Issue" + name], self)) ] ]

    def __make_reloc(self, type, addr, value):
        return [ [ type, addr, value, self.defines ] ]

    def compile(self, filename):
        self.defines = {}
        with open(filename, "r") as f:
            for l in f.readlines():
                if self.re_label.match(l):
                    m = self.re_label.match(l)
                    self.label[m.group(1)] = self.inst_now if self.sect == "text" else self.data_now
                if l.strip() == "":
                    continue
                succ = False
                for ins in self.asm_ins:
                    if ins[0].match(l) != None:
                        ins[1](ins[0].match(l))
                        succ = True
                        break
                if self.mode == "MIPS":
                    for ins in self.mips_ins:
                        if ins[0].match(l) != None:
                            ins[1](ins[0].match(l))
                            succ = True
                            break
                elif self.mode == "Y86":
                    for ins in self.y86_ins:
                        if ins[0].match(l) != None:
                            ins[1](ins[0].match(l))
                            succ = True
                            break
                if not succ:
                    raise BaseException("No such instruction %s" % (l))
        for i in self.exports:
            if not self.defines.has_key(i):
                raise BaseException("No such local variable %s to export" % (i))
            if self.globals.has_key(i):
                raise BaseException("Duplicated export of %s" % (i))
            self.globals[i] = self.defines[i]
            del self.defines[i]

    def relocate(self):
        for r in self.reloc:
            tmp = r[2]
            while True:
                for d in self.defines.keys():
                    tmp = tmp.replace(d, self.defines[d])
                if tmp == r[2]:
                    break
                r[2] = tmp
            try:
                if r[0] == "MIPS_IMM":
                    imm = eval(r[2], self.label)
                    if imm > 0xffff:
                        print >>sys.stderr, "Warning: imm '%s' overflow" % (r[2])
                    r[1][0].set(r[1][1], [ imm & 0xff, (imm >> 8) & 0xff ])
                elif r[0] == "MIPS_OFF":
                    target = eval(r[2], self.label)
                    target -= (r[1][1] + 4)
                    if target & 0x3 != 0:
                        print >>sys.stderr, "Error: pc offset '%s' not aligned" % (r[2])
                        sys.exit(1)
                    target = target >> 2
                    if target > 0x7fff or target < -0x8000:
                        print >>sys.stderr, "Error: pc offset '%s' overflow" %(r[2])
                        sys.exit(1)
                    r[1][0].set(r[1][1], [ target & 0xff, (target >> 8) & 0xff ])
                elif r[0] == "MIPS_ADDR":
                    target = eval(r[2], self.label)
                    if target & 0x3 != 0:
                        print >>sys.stderr, "Error: direct jump to '%s' not aligned" % (r[2])
                        sys.exit(1)
                    if (target >> 28) & 0xf != (r[1][1] >> 28) & 0xf:
                        print >>sys.stderr, "Error: direct jump to '%s' overflow" % (r[2])
                        sys.exit(1)
                    target = target >> 2
                    r[1][0].set(r[1][1], [ target & 0xff, (target >> 8) & 0xff, (target >> 16) & 0xff, (r[1][0].get(r[1][1] + 3, 1)[0][0] & 0xfc) | ((target >> 24) & 0x03) ])
                elif r[0] == "WORD":
                    target = eval(r[2], self.label)
                    if target > 0xffffffff or target < -0x100000000:
                        print >>sys.stderr, "Warning: word '%s' overflow" % (r[2])
                    r[1][0].set(r[1][1], [ target & 0xff, (target >> 8) & 0xff, (target >> 16) & 0xff, (target >> 24) & 0xff ])
                elif r[0] == "Y86_IMM":
                    if r[2][0] == "$":
                        r[2] = r[2][1:]
                    target = eval(r[2], self.label)
                    if target > 0xffffffff or target < -0x100000000:
                        print >>sys.stderr, "Warning: word '%s' overflow" % (r[2])
                    r[1][0].set(r[1][1], [ target & 0xff, (target >> 8) & 0xff, (target >> 16) & 0xff, (target >> 24) & 0xff ])
                elif r[0] == "MIPS_Y86_ADDR":
                    target = eval(r[2], self.label)
                    if (target >> 26) & 0x3f != (r[1][1] >> 26) & 0x3f:
                        print >>sys.stderr, "Error: direct jump to '%s' overflow" % (r[2])
                        sys.exit(1)
                    r[1][0].set(r[1][1], [ target & 0xff, (target >> 8) & 0xff, (target >> 16) & 0xff, (r[1][0].get(r[1][1] + 3, 1)[0][0] & 0xfc) | ((target >> 24) & 0x03) ])
                elif r[0] == "Y86_MIPS_ADDR":
                    if r[2][0] == "$":
                        r[2] = r[2][1:]
                    target = eval(r[2], self.label)
                    if target > 0xffffffff or target < -0x100000000:
                        print >>sys.stderr, "Warning: word '%s' overflow" % (r[2])
                    if target & 0x3 != 0:
                        print >>sys.stderr, "Error: direct jump to mips code '%s' not aligned" % (r[2])
                    r[1][0].set(r[1][1], [ target & 0xff, (target >> 8) & 0xff, (target >> 16) & 0xff, (target >> 24) & 0xff ])
                else:
                    raise BaseException("Unknown relocation type '%s'" % (r[0]))
            except:
                print r[2]
                raise

    def __issue(self, bytes, comment):
        if self.sect == "text":
            self.instmem.set(self.inst_now, bytes, comment)
            addr = self.inst_now
            self.inst_now += len(bytes)
            return self.instmem, addr
        elif self.sect == "data":
            self.datamem.set(self.data_now, bytes, comment)
            addr = self.data_now
            self.data_now += len(bytes)
            return self.datamem, addr
        else:
            raise BaseException("Unknown section '%s'" % (self.sect))

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
        self.__issue(__make_mips_ins("R", 0, rs, rt, rd, 0, 0x20), comment)
    def __mips_IssueSub(self, rd, rs, rt, comment):
        self.__issue(__make_mips_ins("R", 0, rs, rt, rd, 0, 0x22), comment)
    def __mips_IssueAnd(self, rd, rs, rt, comment):
        self.__issue(__make_mips_ins("R", 0, rs, rt, rd, 0, 0x24), comment)
    def __mips_IssueOr(self, rd, rs, rt, comment):
        self.__issue(__make_mips_ins("R", 0, rs, rt, rd, 0, 0x25), comment)
    def __mips_IssueXor(self, rd, rs, rt, comment):
        self.__issue(__make_mips_ins("R", 0, rs, rt, rd, 0, 0x26), comment)
    def __mips_IssueSll(self, rd, rt, sa, comment):
        self.__issue(__make_mips_ins("R", 0, 0, rt, rd, sa, 0x00), comment)
    def __mips_IssueSrl(self, rd, rt, sa, comment):
        self.__issue(__make_mips_ins("R", 0, 0, rt, rd, sa, 0x02), comment)
    def __mips_IssueSra(self, rd, rt, sa, comment):
        self.__issue(__make_mips_ins("R", 0, 0, rt, rd, sa, 0x03), comment)
    def __mips_IssueJr(self, rs, comment):
        self.__issue(__make_mips_ins("R", 0, rs, 0, 0, 0, 0x08), comment)
        self.__issue(__make_mips_ins("R", 0, 0, 0, 0, 0, 0), None)
    def __mips_IssueAddi(self, rt, rs, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x08, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueAndi(self, rt, rs, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x0c, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueOri(self, rt, rs, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x0d, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueXori(self, rt, rs, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x0e, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueLw(self, rt, imm, rs, comment):
        addr = self.__issue(__make_mips_ins("I", 0x23, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueSw(self, rt, imm, rs, comment):
        addr = self.__issue(__make_mips_ins("I", 0x2b, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueBeq(self, rs, rt, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x04, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_OFF", addr, imm)
        self.__issue(__make_mips_ins("R", 0, 0, 0, 0, 0, 0), None)
    def __mips_IssueBne(self, rs, rt, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x05, rs, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_OFF", addr, imm)
        self.__issue(__make_mips_ins("R", 0, 0, 0, 0, 0, 0), None)
    def __mips_IssueLui(self, rt, imm, comment):
        addr = self.__issue(__make_mips_ins("I", 0x0f, 0, rt, 0), comment)
        self.reloc += self.__make_reloc("MIPS_IMM", addr, imm)
    def __mips_IssueJ(self, addr, comment):
        myaddr = self.__issue(__make_mips_ins("J", 0x02, 0), comment)
        self.reloc += self.__make_reloc("MIPS_ADDR", myaddr, addr)
        self.__issue(__make_mips_ins("R", 0, 0, 0, 0, 0, 0), None)
    def __mips_IssueJal(self, addr, comment):
        myaddr = self.__issue(__make_mips_ins("J", 0x03, 0), comment)
        self.reloc += self.__make_reloc("MIPS_ADDR", myaddr, addr)
        self.__issue(__make_mips_ins("R", 0, 0, 0, 0, 0, 0), None)
    def __mips_IssueJY86(self, addr, comment):
        myaddr = self.__issue(__make_mips_ins("J", 0x3a, 0), comment)
        self.reloc += self.__make_reloc("MIPS_Y86_ADDR", myaddr, addr)
        self.__issue(__make_mips_ins("R", 0, 0, 0, 0, 0, 0), None)
    def __mips_IssueSrlv(self, rd, rs, rt, comment):
        self.__issue(__make_mips_ins("R", 0, rs, rt, rd, 0, 0x06), comment)

    def __y86_generateN(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s*%%COMMENT?$"))
    def __y86_resolvN(func):
        return lambda match: func(__cut_tail_newline(match.group(0)))
    def __y86_generateRR(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%REG)\s*,\s*(%%REG)\s*%%COMMENT?$"))
    def __y86_resolvRR(func):
        return lambda match: func(__resolvY86Reg(match.group(1)), __resolvY86Reg(match.group(2)), __cut_tail_newline(match.group(0)))
    def __y86_generateIR(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%IMM)\s*,\s*(%%REG)\s*%%COMMENT?$"))
    def __y86_resolvIR(func):
        return lambda match: func(match.group(1), __resolvY86Reg(match.group(2)), __cut_tail_newline(match.group(0)))
    def __y86_generateRIR(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%REG)\s*,\s*(%%IMM)?\s*\(\s*(%%REG)\s*\)\s*%%COMMENT?$"))
    def __y86_resolvRIR(func):
        return lambda match: \
            func(__resolvY86Reg(match.group(1)), match.group(2), __resolvY86Reg(match.group(3)), __cut_tail_newline(match.group(0))) \
            if match.group(2) != None else \
            func(__resolvY86Reg(match.group(1)), "0", __resolvY86Reg(match.group(3)), __cut_tail_newline(match.group(0)))
    def __y86_generateIRR(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%IMM)?\s*\(\s*(%%REG)\s*\)\s*,\s*(%%REG)\s*%%COMMENT?$"))
    def __y86_resolvIRR(func):
        return lambda match: \
            func(match.group(1), __resolvY86Reg(match.group(2)), __resolvY86Reg(match.group(3)), __cut_tail_newline(match.group(0))) \
            if match.group(1) != None else \
            func("0", __resolvY86Reg(match.group(2)), __resolvY86Reg(match.group(3)), __cut_tail_newline(match.group(0)))
    def __y86_generateI(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%IMM)\s*%%COMMENT?$"))
    def __y86_resolvI(func):
        return lambda match: func(match.group(1), __cut_tail_newline(match.group(0)))
    def __y86_generateIC(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"(%%COND)\s+(%%IMM)\s*%%COMMENT?$"))
    def __y86_resolvIC(func):
        return lambda match: func(__resolvY86Cond(match.group(1)), match.group(2), __cut_tail_newline(match.group(0)))
    def __y86_generateRRC(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"(%%COND)\s+(%%REG)\s*,\s*(%%REG)\s*%%COMMENT?$"))
    def __y86_resolvRRC(func):
        return lambda match: func(__resolvY86Cond(match.group(1)), __resolvY86Reg(match.group(2)), __resolvY86Reg(match.group(3)), __cut_tail_newline(match.group(0)))
    def __y86_generateR(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%REG)\s*%%COMMENT?$"))
    def __y86_resolvR(func):
        return lambda match: func(__resolvY86Reg(match.group(1)), __cut_tail_newline(match.group(0)))
    def __y86_generateRI(name):
        return re.compile(__applyTemplate(__y86Temp, r"^(?:\s*%%ID\s*:)?\s*" + name + r"\s+(%%REG)\s*,\s*(%%IMM)\s*%%COMMENT?$"))
    def __y86_resolvRI(func):
        return lambda match: func(__resolvY86Reg(match.group(1)), match.group(2), __cut_tail_newline(match.group(0)))

    def __y86_IssueHalt(self, comment):
        self.__issue(__make_y86_ins("1", 0x00), comment)
    def __y86_IssueNop(self, comment):
        self.__issue(__make_y86_ins("1", 0x10), comment)
    def __y86_IssueRrmovl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x20, ra, rb), comment)
    def __y86_IssueIrmovl(self, V, rb, comment):
        addr = self.__issue(__make_y86_ins("6", 0x30, 0xf, rb, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), V)
    def __y86_IssueRmmovl(self, ra, D, rb, comment):
        addr = self.__issue(__make_y86_ins("6", 0x40, ra, rb, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), D)
    def __y86_IssueMrmovl(self, D, rb, ra, comment):
        addr = self.__issue(__make_y86_ins("6", 0x50, ra, rb, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), D)
    def __y86_IssueAddl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x60, ra, rb), comment)
    def __y86_IssueSubl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x61, ra, rb), comment)
    def __y86_IssueAndl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x62, ra, rb), comment)
    def __y86_IssueXorl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x63, ra, rb), comment)
    def __y86_IssueOrl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x64, ra, rb), comment)
    def __y86_IssueJmp(self, Dest, comment):
        addr = self.__issue(__make_y86_ins("5", 0x70, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 1 ), Dest)
    def __y86_IssueJ(self, cond, Dest, comment):
        addr = self.__issue(__make_y86_ins("5", 0x70 | cond, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 1 ), Dest)
    def __y86_IssueCmov(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x20 | cond, ra, rb), comment)
    def __y86_IssueCall(self, Dest, comment):
        addr = self.__issue(__make_y86_ins("5", 0x80, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 1 ), Dest)
    def __y86_IssueRet(self, comment):
        self.__issue(__make_y86_ins("1", 0x90), comment)
    def __y86_IssuePushl(self, ra, comment):
        self.__issue(__make_y86_ins("2", 0xa0, ra, 0xf), comment)
    def __y86_IssuePopl(self, ra, comment):
        self.__issue(__make_y86_ins("2", 0xb0, ra, 0xf), comment)
    def __y86_IssueJMIPS(self, Dest, comment):
        addr = self.__issue(__make_y86_ins("5", 0xc0, 0), comment)
        self.reloc += self.__make_reloc("Y86_MIPS_ADDR", ( addr[0], addr[1] + 1 ), Dest)

    def __y86_IssueCmpi(self, ra, V, comment):
        addr = self.__issue(__make_y86_ins("6", 0xe6, ra, 0xf, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), V)
    def __y86_IssueCmpl(self, ra, rb, comment):
        self.__issue(__make_y86_ins("2", 0x66, ra, rb), comment)

    def __y86_IssueIaddl(self, V, rb, comment):
        addr = self.__issue(__make_y86_ins("6", 0xd0, 0xf, rb, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), V)
    def __y86_IssueIsubl(self, V, rb, comment):
        addr = self.__issue(__make_y86_ins("6", 0xd1, 0xf, rb, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), V)
    def __y86_IssueIorl(self, V, rb, comment):
        addr = self.__issue(__make_y86_ins("6", 0xd4, 0xf, rb, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), V)
    def __y86_IssueSlli(self, ra, V, comment):
        addr = self.__issue(__make_y86_ins("6", 0xe5, ra, 0xf, 0), comment)
        self.reloc += self.__make_reloc("Y86_IMM", ( addr[0], addr[1] + 2 ), V)

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
        return lambda match: func(match.group(1), __cut_tail_newline(match.group(0)))
    def __asm_generateNull(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*(#.*)?$")
    def __asm_resolvNull(func):
        return lambda match: func()
    def __asm_generateDefine(name):
        return re.compile(r"^(?:\s*[_a-zA-Z][_0-9a-zA-Z]*\s*:)?\s*\." + name + r"\s+([^#\r\n \t]+)\s+([^#\r\n]+)\s+(#.*)?$")
    def __asm_resolvDefine(func):
        return lambda match: func(match.group(1), match.group(2), __cut_tail_newline(match.group(0)))

    def __asm_IssueText(self):
        self.sect = "text"
    def __asm_IssueData(self):
        self.sect = "data"
    def __asm_IssueOrg(self, now):
        if self.sect == "text":
            self.inst_now = now
        elif self.sect == "data":
            self.data_now = now
        else:
            raise BaseException("Unknown section '%s'" % (self.sect))
    def __asm_IssueWord(self, data, comment):
        addr = self.__issue([0] * 4, comment)
        self.reloc += self.__make_reloc("WORD", addr, data)
    def __asm_IssueNull(self):
        pass
    def __asm_IssueMIPS(self):
        self.mode = "MIPS"
    def __asm_IssueY86(self):
        self.mode = "Y86"
    def __asm_IssueDefine(self, name, value, comment):
        self.defines[name] = value

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print >>sys.stderr, "Usage: %s <xxx.S>" % (sys.argv[0])
        sys.exit(1)
    assembler = Assembler()
    assembler.compile(sys.argv[1])
    assembler.relocate()
    assembler.instmem.dump()
    assembler.datamem.dump()
