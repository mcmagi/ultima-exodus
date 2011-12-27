ROOT=../..
include ${ROOT}/Makefile.dos.include

all: mkdirs ${UTILBIN}/color.com ${UTILBIN}/vga.com ${UTILBIN}/cgacomp.com \
        ${UTILBIN}/vgacolor.com

mkdirs: ${UTILBIN}

${UTILBIN}/color.com: color.asm
	${ASM} color.asm ${UTILBIN}/color.com

${UTILBIN}/vgacolor.com: vgacolor.asm ../common/loadfile.asm
	${ASM} vgacolor.asm ${UTILBIN}/vgacolor.com

${UTILBIN}/vga.com: vga.asm
	${ASM} vga.asm ${UTILBIN}/vga.com

${UTILBIN}/cgacomp.com: cgacomp.asm ../common/savefile.asm
	${ASM} cgacomp.asm ${UTILBIN}/cgacomp.com

clean:
	rm ${UTILBIN}/color.com
	rm ${UTILBIN}/vgacolor.com
	rm ${UTILBIN}/vga.com
	rm ${UTILBIN}/cgacomp.com