ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U3BIN}/sosaria.mod

${U3BIN}/sosaria.mod: sosaria.asm | ${U3BIN}
	${ASM} sosaria.asm ${U3BIN}/sosaria.mod

clean:
	rm ${U3BIN}/sosaria.mod

package: package_u3

package_u3:
	cp -f ${U3BIN}/sosaria.mod ${U3PKG}
