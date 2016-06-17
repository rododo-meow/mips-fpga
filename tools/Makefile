.PHONY: clean

INSTMEM_SIZE=2048
DATAMEM_SIZE=4096

MENU_APP = helloworld.S y86ballgame.S y86ball.S about.S
LIBS := print.S key.S vga.S sw.S gui.S seg.S

build-%: %.inst.mif %.data.mif
	@exit 0

%.inst.mif: %.S compiler.py memory.py assembler.py mifutil.py
	@./compiler.py $*.inst.mif $(INSTMEM_SIZE) - - $*.S

%.data.mif: %.S compiler.py memory.py assembler.py mifutil.py
	@./compiler.py - - $*.data.mif $(DATAMEM_SIZE) $*.S

install-%: %.inst.mif %.data.mif
	@cp $*.inst.mif ../source/sc_instmem.mif
	@cp $*.data.mif ../source/sc_datamem.mif
	@cp ../source/sc_instmem.mif ../source/sc_datamem.mif ../modelsim/source/

app.inst.mif: menu.S $(MENU_APP) $(LIBS)
	@./compiler.py $@ $(INSTMEM_SIZE) - -  $^

app.data.mif: menu.S $(MENU_APP) $(LIBS)
	@./compiler.py - - $@ $(DATAMEM_SIZE) $^

clean:
	@rm -f *.mif
	@rm -f *.pyc
