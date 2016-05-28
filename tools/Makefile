.PHONY: clean

INSTMEM_SIZE=1024
DATAMEM_SIZE=256

build-%: compiler.py memory.py assembler.py mifutil.py
	@./compiler.py $*.inst.mif $(INSTMEM_SIZE) $*.data.mif $(DATAMEM_SIZE) $*.S

clean:
	rm -f *.mif
