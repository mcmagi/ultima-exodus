ROOT=../..
include ${ROOT}/Makefile.include

compile: ${UTILBIN}/color.com ${UTILBIN}/vga.com ${UTILBIN}/cgacomp.com \
        ${UTILBIN}/vgacolor.com

${UTILBIN}/color.com: color.asm | ${UTILBIN}
	${ASM} color.asm ${UTILBIN}/color.com

${UTILBIN}/vgacolor.com: vgacolor.asm ../common/loadfile.asm | ${UTILBIN}
	${ASM} vgacolor.asm ${UTILBIN}/vgacolor.com

${UTILBIN}/vga.com: vga.asm | ${UTILBIN}
	${ASM} vga.asm ${UTILBIN}/vga.com

${UTILBIN}/cgacomp.com: cgacomp.asm ../common/savefile.asm | ${UTILBIN}
	${ASM} cgacomp.asm ${UTILBIN}/cgacomp.com

clean:
	rm ${UTILBIN}/color.com
	rm ${UTILBIN}/vgacolor.com
	rm ${UTILBIN}/vga.com
	rm ${UTILBIN}/cgacomp.com
