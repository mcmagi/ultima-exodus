ROOT=../..
include ${ROOT}/Makefile.dos.include

all: mkdirs ${U5BIN}/mid.drv

mkdirs: ${U5BIN}

${U5BIN}/mid.drv: midi.asm
	${ASM} midi.asm ${U5BIN}/mid.drv

clean:
	rm ${U5BIN}/mid.drv