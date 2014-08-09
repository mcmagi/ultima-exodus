ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U3BIN}/cga.drv ${U3BIN}/cgacomp.drv ${U3BIN}/ega.drv ${U3BIN}/vga.drv \
        ${U3BIN}/midpak.drv ${U3BIN}/nomidi.drv ${U3BIN}/sfx.drv ${U3BIN}/sfxtimed.drv ${U3BIN}/sfxtest.com

VIDDEPS=vidjmp.asm vidfile.asm vidfar.asm ../common/loadfile.asm \
    ../common/xchgs.asm ../common/memory.asm

${U3BIN}/cga.drv: cga.asm cgacore.asm ${VIDDEPS} | ${U3BIN}
	${ASM} cga.asm ${U3BIN}/cga.drv

${U3BIN}/cgacomp.drv: cgacomp.asm cgacore.asm ${VIDDEPS} palette.asm | ${U3BIN}
	${ASM} cgacomp.asm ${U3BIN}/cgacomp.drv

${U3BIN}/ega.drv: ega.asm ${VIDDEPS} | ${U3BIN}
	${ASM} ega.asm ${U3BIN}/ega.drv

${U3BIN}/vga.drv: vga.asm ${VIDDEPS} palette.asm | ${U3BIN}
	${ASM} vga.asm ${U3BIN}/vga.drv

${U3BIN}/midpak.drv: midpak.asm | ${U3BIN}
	${ASM} midpak.asm ${U3BIN}/midpak.drv

${U3BIN}/nomidi.drv: nomidi.asm | ${U3BIN}
	${ASM} nomidi.asm ${U3BIN}/nomidi.drv

${U3BIN}/sfx.drv: sfx.asm sfxfar.asm sfxjmp.asm | ${U3BIN}
	${ASM} sfx.asm ${U3BIN}/sfx.drv

${U3BIN}/sfxtimed.drv: sfxtimed.asm sfxfar.asm sfxjmp.asm | ${U3BIN}
	${ASM} sfxtimed.asm ${U3BIN}/sfxtimed.drv

${U3BIN}/sfxtest.com: sfxtest.asm ../common/loadfile.asm ../common/xchgs.asm ../common/memory.asm ../launcher/timer.asm ../launcher/vector.asm | ${U3BIN}
	${ASM} sfxtest.asm ${U3BIN}/sfxtest.com

clean:
	rm ${U3BIN}/cga.drv
	rm ${U3BIN}/cgacomp.drv
	rm ${U3BIN}/ega.drv
	rm ${U3BIN}/vga.drv
	rm ${U3BIN}/midpak.drv
	rm ${U3BIN}/nomidi.drv
	rm ${U3BIN}/sfx.drv
	rm ${U3BIN}/sfxtimed.drv
	rm ${U3BIN}/sfxtest.com

package: package_u3

package_u3:
	cp -f ${U3BIN}/cga.drv ${U3PKG}
	cp -f ${U3BIN}/cgacomp.drv ${U3PKG}
	cp -f ${U3BIN}/ega.drv ${U3PKG}
	cp -f ${U3BIN}/vga.drv ${U3PKG}
	cp -f ${U3BIN}/nomidi.drv ${U3PKG}
	cp -f ${U3BIN}/midpak.drv ${U3PKG}
