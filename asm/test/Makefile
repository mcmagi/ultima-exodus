ROOT=../..
include ${ROOT}/Makefile.include

compile: ${UTILBIN}/strtest.com

${UTILBIN}/strtest.com: strtest.asm ../common/strcpy.asm | ${UTILBIN}
	${ASM} strtest.asm ${UTILBIN}/strtest.com

clean:
	rm ${UTILBIN}/strtest.mod