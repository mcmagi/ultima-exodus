ROOT=../..
include ${ROOT}/Makefile.include

HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h patchadd.h patch.h

compile: mkdirs ${UTILBIN}/bindiff ${UTILBIN}/binpat ${UTILBIN}/binunpat

mkdirs: ${BINPATCH_LIB} ${UTILBIN}

${BINPATCH_LIB}:
	mkdir -p ${BINPATCH_LIB}

# object files
${BINPATCH_LIB}/bindiff.o: bindiff.c bindiff.h ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/bindiff.o, bindiff.c)

${BINPATCH_LIB}/binpatch.o: binpatch.c binpatch.h ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/binpatch.o, binpatch.c)

${BINPATCH_LIB}/binunpatch.o: binunpatch.c binunpatch.h ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/binunpatch.o, binunpatch.c)

${BINPATCH_LIB}/patch.o: patch.c patch.h
	$(call compile, ${BINPATCH_LIB}/patch.o, patch.c)

${BINPATCH_LIB}/patchadd.o: patchadd.c ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/patchadd.o, patchadd.c)

# binary files
# NOTE: Windows 7 requires Admin rights to 'binpatch.exe'. But 'binpat.exe' is okay.  (WTF?!)
${UTILBIN}/binpat: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o ${BINPATCH_LIB}/patch.o
	$(call link, ${UTILBIN}/binpat, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o \
		${BINPATCH_LIB}/patch.o)

${UTILBIN}/binunpat: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binunpatch.o ${BINPATCH_LIB}/patch.o
	$(call link, ${UTILBIN}/binunpat, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binunpatch.o \
		${BINPATCH_LIB}/patch.o)

${UTILBIN}/bindiff: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchadd.o
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
	cp -f ${UTILBIN}/binpat ${U2PKG}
	cp -f ${UTILBIN}/binunpat ${U2PKG}

package_u3: ${UTILBIN}/binpat ${UTILBIN}/binunpat
	cp -f ${UTILBIN}/binpat ${U3PKG}
	cp -f ${UTILBIN}/binunpat ${U3PKG}

package_u5: ${UTILBIN}/binpat ${UTILBIN}/binunpat
	cp -f ${UTILBIN}/binpat ${U5PKG}
	cp -f ${UTILBIN}/binunpat ${U5PKG}
