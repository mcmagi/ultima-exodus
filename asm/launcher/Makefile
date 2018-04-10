ROOT=../..
include ${ROOT}/Makefile.include

DEPS=core.asm interrupts.asm timer.asm vector.asm ../common/loadfile.asm \
    ../common/strcpy.asm

compile: ${U2BIN}/ultima2.com ${U3BIN}/ultima3.com ${U5BIN}/ultima5.com

${U2BIN}/ultima2.com: ultima2.asm ${DEPS} | ${U2BIN}
	${ASM} ultima2.asm ${U2BIN}/ultima2.com

${U3BIN}/ultima3.com: ultima3.asm ${DEPS} | ${U3BIN}
	${ASM} ultima3.asm ${U3BIN}/ultima3.com

${U5BIN}/ultima5.com: ultima5.asm | ${U5BIN}
	${ASM} ultima5.asm ${U5BIN}/ultima5.com

clean:
	rm ${U2BIN}/ultima2.com
	rm ${U3BIN}/ultima3.com
	rm ${U5BIN}/ultima5.com

package: package_u3

package_u2:
	cp -f ${U2BIN}/ultima2.com ${U2PKG}

package_u3:
	cp -f ${U3BIN}/ultima3.com ${U3PKG}

package_u5:
	cp -f ${U5BIN}/ultima5.com ${U5PKG}
