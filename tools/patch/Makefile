ROOT=../..
include ${ROOT}/Makefile.${TARGET}.include

COMMON_HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h

all: mkdirs ${U2BIN}/cgapatch ${U2BIN}/dngpatch ${U5BIN}/u5data

mkdirs: ${PATCH_LIB} ${U2BIN} ${U5BIN}

${PATCH_LIB}:
	mkdir -p ${PATCH_LIB}

# object files
${PATCH_LIB}/cgapatch.o: cgapatch.c u2patch.h ${COMMON_HEADERS}
	$(call compile, ${PATCH_LIB}/cgapatch.o, cgapatch.c)

${PATCH_LIB}/dngpatch.o: dngpatch.c u2patch.h ${COMMON_HEADERS}
	$(call compile, ${PATCH_LIB}/dngpatch.o, dngpatch.c)

${PATCH_LIB}/u5data.o: u5data.c u5patch.h ${COMMON_HEADERS}
	$(call compile, ${PATCH_LIB}/u5data.o, u5data.c)

${PATCH_LIB}/patch.o: patch.c ${COMMON_HEADERS}
	$(call compile, ${PATCH_LIB}/patch.o, patch.c)

# binary files
${U2BIN}/cgapatch: ${COMMON_LIB}/File.o ${PATCH_LIB}/cgapatch.o
	$(call link, ${U2BIN}/cgapatch, ${COMMON_LIB}/File.o ${PATCH_LIB}/cgapatch.o)

${U2BIN}/dngpatch: ${COMMON_LIB}/File.o ${PATCH_LIB}/dngpatch.o
	$(call link, ${U2BIN}/dngpatch, ${COMMON_LIB}/File.o ${PATCH_LIB}/dngpatch.o)

${U5BIN}/u5data: ${COMMON_LIB}/File.o ${PATCH_LIB}/u5data.o ${PATCH_LIB}/patch.o
	$(call link, ${U5BIN}/u5data, ${COMMON_LIB}/File.o ${PATCH_LIB}/u5data.o ${PATCH_LIB}/patch.o)

# clean
clean:
	rm ${PATCH_LIB}/*.o
	rm ${U2BIN}/cgapatch
	rm ${U2BIN}/dngpatch
	rm ${U5BIN}/u5data
