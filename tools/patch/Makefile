ROOT=../..
include ${ROOT}/Makefile.include

COMMON_HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h

compile: ${U2BIN}/cgapatch ${U2BIN}/dngpatch ${U5BIN}/u5data

${PATCH_LIB}:
	mkdir -p ${PATCH_LIB}

# object files
${PATCH_LIB}/cgapatch.o: cgapatch.c u2patch.h ${COMMON_HEADERS} | ${PATCH_LIB}
	$(call compile, ${PATCH_LIB}/cgapatch.o, cgapatch.c)

${PATCH_LIB}/dngpatch.o: dngpatch.c u2patch.h ${COMMON_HEADERS} | ${PATCH_LIB}
	$(call compile, ${PATCH_LIB}/dngpatch.o, dngpatch.c)

${PATCH_LIB}/u5data.o: u5data.c u5patch.h ${COMMON_HEADERS} | ${PATCH_LIB}
	$(call compile, ${PATCH_LIB}/u5data.o, u5data.c)

${PATCH_LIB}/patch.o: patch.c ${COMMON_HEADERS} | ${PATCH_LIB}
	$(call compile, ${PATCH_LIB}/patch.o, patch.c)

# binary files
${U2BIN}/cgapatch: ${COMMON_LIB}/File.o ${PATCH_LIB}/cgapatch.o | ${U2BIN}
	$(call link, ${U2BIN}/cgapatch, ${COMMON_LIB}/File.o ${PATCH_LIB}/cgapatch.o)

${U2BIN}/dngpatch: ${COMMON_LIB}/File.o ${PATCH_LIB}/dngpatch.o | ${U2BIN}
	$(call link, ${U2BIN}/dngpatch, ${COMMON_LIB}/File.o ${PATCH_LIB}/dngpatch.o)

${U5BIN}/u5data: ${COMMON_LIB}/File.o ${PATCH_LIB}/u5data.o ${PATCH_LIB}/patch.o | ${U5BIN}
	$(call link, ${U5BIN}/u5data, ${COMMON_LIB}/File.o ${PATCH_LIB}/u5data.o ${PATCH_LIB}/patch.o)

# clean
clean:
	rm ${PATCH_LIB}/*.o
	rm ${U2BIN}/cgapatch
	rm ${U2BIN}/dngpatch
	rm ${U5BIN}/u5data

# these tools no longer get packaged, in favor of binpatch
