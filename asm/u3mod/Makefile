ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U3BIN}/ultima3.mod ${U3BIN}/sosaria.mod

${U3BIN}/ultima3.mod: ultima3.asm modcore.asm modfar.asm modjmp.asm | ${U3BIN}
	${ASM} ultima3.asm ${U3BIN}/ultima3.mod

${U3BIN}/sosaria.mod: sosaria.asm modcore.asm modfar.asm modjmp.asm | ${U3BIN}
	${ASM} sosaria.asm ${U3BIN}/sosaria.mod

clean:
	rm -f ${U3BIN}/ultima3.mod
	rm -f ${U3BIN}/sosaria.mod

package: package_u3

package_u3:
	cp -f ${U3BIN}/ultima3.mod ${U3PKG}
	cp -f ${U3BIN}/sosaria.mod ${U3PKG}
