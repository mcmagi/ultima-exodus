ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U3BIN}/sosaria.mod ${U3BIN}/lolb.mod

${U3BIN}/sosaria.mod: sosaria.asm modcore.asm modfar.asm modjmp.asm | ${U3BIN}
	${ASM} sosaria.asm ${U3BIN}/sosaria.mod

${U3BIN}/lolb.mod: lolb.asm modcore.asm modfar.asm modjmp.asm | ${U3BIN}
	${ASM} lolb.asm ${U3BIN}/lolb.mod

clean:
	rm ${U3BIN}/sosaria.mod
	rm ${U3BIN}/lolb.mod

package: package_u3

package_u3:
	cp -f ${U3BIN}/sosaria.mod ${U3PKG}
	cp -f ${U3BIN}/lolb.mod ${U3PKG}
