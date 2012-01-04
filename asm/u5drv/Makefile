ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U5BIN}/mid.drv

${U5BIN}/mid.drv: midi.asm | ${U5BIN}
	${ASM} midi.asm ${U5BIN}/mid.drv

clean:
	rm ${U5BIN}/mid.drv

package: package_u5

package_u5:
	cp -f ${U5BIN}/mid.drv ${U5PKG}
