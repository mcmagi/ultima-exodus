ROOT=../..
include ${ROOT}/Makefile.include

all: mkdirs ${U2BIN}/ultima2.com ${U3BIN}/ultima3.com ${U5BIN}/ultima5.com

mkdirs: ${U2BIN} ${U3BIN} ${U5BIN}

${U2BIN}/ultima2.com: ultima2.asm
	${ASM} ultima2.asm ${U2BIN}/ultima2.com

${U3BIN}/ultima3.com: ultima3.asm ../common/loadfile.asm ../common/strcpy.asm
	${ASM} ultima3.asm ${U3BIN}/ultima3.com

${U5BIN}/ultima5.com: ultima5.asm ${VIDDEPS}
	${ASM} ultima5.asm ${U5BIN}/ultima5.com

clean:
	rm ${U2BIN}/ultima2.com
	rm ${U3BIN}/ultima3.com
	rm ${U5BIN}/ultima5.com