ROOT=../..
include ${ROOT}/Makefile.include

all: mkdirs ${U3BIN}/cga.drv ${U3BIN}/cgacomp.drv ${U3BIN}/ega.drv ${U3BIN}/vga.drv \
        ${U3BIN}/midpak.drv ${U3BIN}/nomidi.drv

mkdirs: ${U3BIN}

VIDDEPS=vidjmp.asm vidfile.asm vidfar.asm ../common/loadfile.asm \
    ../common/xchgs.asm ../common/memory.asm

${U3BIN}/cga.drv: cga.asm cgacore.asm ${VIDDEPS}
	${ASM} cga.asm ${U3BIN}/cga.drv

${U3BIN}/cgacomp.drv: cgacomp.asm cgacore.asm ${VIDDEPS} palette.asm
	${ASM} cgacomp.asm ${U3BIN}/cgacomp.drv

${U3BIN}/ega.drv: ega.asm ${VIDDEPS}
	${ASM} ega.asm ${U3BIN}/ega.drv

${U3BIN}/vga.drv: vga.asm ${VIDDEPS} palette.asm
	${ASM} vga.asm ${U3BIN}/vga.drv

${U3BIN}/midpak.drv: midpak.asm
	${ASM} midpak.asm ${U3BIN}/midpak.drv

${U3BIN}/nomidi.drv: nomidi.asm
	${ASM} nomidi.asm ${U3BIN}/nomidi.drv

clean:
	rm ${U3BIN}/cga.drv
	rm ${U3BIN}/cgacomp.drv
	rm ${U3BIN}/ega.drv
	rm ${U3BIN}/vga.drv
	rm ${U3BIN}/midpak.drv
	rm ${U3BIN}/nomidi.drv