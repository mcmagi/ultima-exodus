ROOT=../..
include ${ROOT}/Makefile.include

HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h patch.h

compile: ${UTILBIN}/bindiff ${UTILBIN}/binpat ${UTILBIN}/binunpat

${BINPATCH_LIB}:
	mkdir -p ${BINPATCH_LIB}

# object files
${BINPATCH_LIB}/bindiff.o: bindiff.c bindiff.h patchadd.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/bindiff.o, bindiff.c)

${BINPATCH_LIB}/binpatch.o: binpatch.c binpatch.h patchapply.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/binpatch.o, binpatch.c)

${BINPATCH_LIB}/binunpatch.o: binunpatch.c binunpatch.h patchunapply.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/binunpatch.o, binunpatch.c)

${BINPATCH_LIB}/patch.o: patch.c patch.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/patch.o, patch.c)

${BINPATCH_LIB}/patchadd.o: patchadd.c patchadd.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/patchadd.o, patchadd.c)

${BINPATCH_LIB}/patchapply.o: patchapply.c patchapply.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/patchapply.o, patchapply.c)

${BINPATCH_LIB}/patchunapply.o: patchunapply.c patchunapply.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/patchunapply.o, patchunapply.c)

# binary files
# NOTE: Windows 7 requires Admin rights to 'binpatch.exe'. But 'binpat.exe' is okay.  (WTF?!)
${UTILBIN}/binpat: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchapply.o | ${UTILBIN}
	$(call link, ${UTILBIN}/binpat, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchapply.o)

${UTILBIN}/binunpat: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binunpatch.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchunapply.o | ${UTILBIN}
	$(call link, ${UTILBIN}/binunpat, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binunpatch.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchunapply.o)

${UTILBIN}/bindiff: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchadd.o | ${UTILBIN}
	$(call link, ${UTILBIN}/bindiff, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchadd.o)

# clean
clean:
	rm ${BINPATCH_LIB}/*.o
	rm ${UTILBIN}/bindiff
	rm ${UTILBIN}/binpat
	rm ${UTILBIN}/binunpat

# package
package: package_u2 package_u3 package_u5

package_u2: ${UTILBIN}/binpat ${UTILBIN}/binunpat
	cp -f ${UTILBIN}/binpat ${U2PKG}/binpat${BINSUFFIX}
	cp -f ${UTILBIN}/binunpat ${U2PKG}/binunpat${BINSUFFIX}

package_u3: ${UTILBIN}/binpat ${UTILBIN}/binunpat
	cp -f ${UTILBIN}/binpat ${U3PKG}/binpat${BINSUFFIX}
	cp -f ${UTILBIN}/binunpat ${U3PKG}/binunpat${BINSUFFIX}

package_u5: ${UTILBIN}/binpat ${UTILBIN}/binunpat
	cp -f ${UTILBIN}/binpat ${U5PKG}/binpat${BINSUFFIX}
	cp -f ${UTILBIN}/binunpat ${U5PKG}/binunpat${BINSUFFIX}
