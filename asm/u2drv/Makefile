ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U2BIN}/cga.drv ${U2BIN}/ega.drv

VIDDEPS=vidjmp.asm ../common/vidfile.asm vidfar.asm ../common/loadfile.asm \
    ../common/memory.asm

${U2BIN}/cga.drv: cga.asm ${VIDDEPS} | ${U2BIN}
	${ASM} cga.asm ${U2BIN}/cga.drv

${U2BIN}/ega.drv: ega.asm ${VIDDEPS} | ${U2BIN}
	${ASM} ega.asm ${U2BIN}/ega.drv

clean:
	rm ${U2BIN}/cga.drv
	rm ${U2BIN}/ega.drv

package: package_u2

package_u2:
	cp -f ${U2BIN}/cga.drv ${U2PKG}
	cp -f ${U2BIN}/ega.drv ${U2PKG}
