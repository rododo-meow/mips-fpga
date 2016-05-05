.PHONY: all test.o clean
.PRECIOUS: %.data.mif %.inst.mif

all: test.o

%.inst.mif: %.S
	@mips-linux-gnu-as -mips32 --gstabs -g -o $*.o.$$$$ $< && \
	 mips-linux-gnu-objdump -d -S $*.o.$$$$ | ./genmif.py $@; \
	 rm $*.o.$$$$

%.data.mif: %.S
	@mips-linux-gnu-as -mips32 --gstabs -g -o $*.o.$$$$ $< && \
	 mips-linux-gnu-objcopy -j ".data" -O binary $*.o.$$$$ && \
	 ./gendatamif.py $*.o.$$$$ $@; \
	 rm $*.o.$$$$

build-%: %.inst.mif %.data.mif
	@exit 0

clean:
	rm -f *.mif
