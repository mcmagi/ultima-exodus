ROOT=../..
include ${ROOT}/Makefile.include

HEADERS=${COMMON}/File.h ${COMMON}/DirList.h ${COMMON}/gendefs.h ${COMMON}/option.h \
		${COMMON}/IniCfg.h ${COMMON}/filepath.h ${COMMON}/stringutil.h ${COMMON}/debug.h \
		${COMMON}/List.h patch.h
LIBS=${COMMON_LIB}/File.o ${COMMON_LIB}/filepath.o ${COMMON_LIB}/stringutil.o \
		${COMMON_LIB}/List.o ${COMMON_LIB}/debug.o

compile: ${UTILBIN}/bindiff ${UTILBIN}/binpat ${UTILBIN}/binunpat ${UTILBIN}/upgrade

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

${BINPATCH_LIB}/upgrade.o: upgrade.c upgrade.h patch.h patchapply.h patchunapply.h ${HEADERS} | ${BINPATCH_LIB}
	$(call compile, ${BINPATCH_LIB}/upgrade.o, upgrade.c)

# binary files
# NOTE: Windows 7 requires Admin rights to 'binpatch.exe'. But 'binpat.exe' is okay.  (WTF?!)
${UTILBIN}/binpat: ${LIBS} ${BINPATCH_LIB}/binpatch.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchapply.o | ${UTILBIN}
	$(call link, ${UTILBIN}/binpat, ${LIBS} ${BINPATCH_LIB}/binpatch.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchapply.o)

${UTILBIN}/binunpat: ${LIBS} ${BINPATCH_LIB}/binunpatch.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchunapply.o | ${UTILBIN}
	$(call link, ${UTILBIN}/binunpat, ${LIBS} ${BINPATCH_LIB}/binunpatch.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchunapply.o)

${UTILBIN}/bindiff: ${LIBS} ${BINPATCH_LIB}/bindiff.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchadd.o | ${UTILBIN}
	$(call link, ${UTILBIN}/bindiff, ${LIBS} ${BINPATCH_LIB}/bindiff.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchadd.o)

${UTILBIN}/upgrade: ${LIBS} ${COMMON_LIB}/DirList.o ${BINPATCH_LIB}/upgrade.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchapply.o ${BINPATCH_LIB}/patchunapply.o ${COMMON_LIB}/IniCfg.o | ${UTILBIN}
	$(call link, ${UTILBIN}/upgrade, ${LIBS} ${COMMON_LIB}/DirList.o \
		${COMMON_LIB}/option.o ${COMMON_LIB}/IniCfg.o ${BINPATCH_LIB}/upgrade.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchapply.o ${BINPATCH_LIB}/patchunapply.o)

# clean
clean:
	rm ${BINPATCH_LIB}/*.o
	rm ${UTILBIN}/bindiff
	rm ${UTILBIN}/binpat
	rm ${UTILBIN}/binunpat
	rm ${UTILBIN}/upgrade

# package
package: package_u2 package_u3 package_u5

package_u2: ${UTILBIN}/upgrade
	cp -f ${UTILBIN}/upgrade ${U2PKG}/u2up${BINSUFFIX}

package_u3: ${UTILBIN}/upgrade
	cp -f ${UTILBIN}/upgrade ${U3PKG}/u3up${BINSUFFIX}

package_u5: ${UTILBIN}/binpat ${UTILBIN}/binunpat
	cp -f ${UTILBIN}/binpat ${U5PKG}/binpat${BINSUFFIX}
	cp -f ${UTILBIN}/binunpat ${U5PKG}/binunpat${BINSUFFIX}
