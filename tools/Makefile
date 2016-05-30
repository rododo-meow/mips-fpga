.PHONY: clean

INSTMEM_SIZE=1024
DATAMEM_SIZE=256

build-%: %.inst.mif
	@exit 0
	
%.inst.mif: %.S compiler.py memory.py assembler.py mifutil.py
	@./compiler.py $*.inst.mif $(INSTMEM_SIZE) $*.data.mif $(DATAMEM_SIZE) $*.S

%.data.mif: %.S compiler.py memory.py assembler.py mifutil.py
	@./compiler.py $*.inst.mif $(INSTMEM_SIZE) $*.data.mif $(DATAMEM_SIZE) $*.S

install-%: %.inst.mif %.data.mif
	@cp $*.inst.mif ../source/sc_instmem.mif
	@cp $*.data.mif ../source/sc_datamem.mif
	@cp ../source/sc_instmem.mif ../source/sc_datamem.mif ../modelsim/

clean:
	@rm -f *.mif
	@rm -f *.pyc
