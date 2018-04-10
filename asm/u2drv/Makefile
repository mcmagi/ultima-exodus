ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U2BIN}/ega.drv

VIDDEPS=vidjmp.asm ../common/vidfile.asm vidfar.asm ../common/loadfile.asm \
    ../common/memory.asm

${U2BIN}/ega.drv: ega.asm ${VIDDEPS} | ${U2BIN}
	${ASM} ega.asm ${U2BIN}/ega.drv

clean:
	rm ${U2BIN}/ega.drv

package: package_u2

package_u3:
	cp -f ${U2BIN}/ega.drv ${U2PKG}
