ROOT=../..
include ${ROOT}/Makefile.include

COMMON_HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h

all: mkdirs ${U2BIN}/cgapatch ${U2BIN}/dngpatch ${U5BIN}/u5data

mkdirs: ${PATCH_LIB} ${U2BIN} ${U5BIN}

${PATCH_LIB}:
	mkdir -p ${PATCH_LIB}

# object files
${PATCH_LIB}/cgapatch.o: cgapatch.c u2patch.h ${COMMON_HEADERS}
	${CC} cgapatch.c -o ${PATCH_LIB}/cgapatch.o

${PATCH_LIB}/dngpatch.o: dngpatch.c u2patch.h ${COMMON_HEADERS}
	${CC} dngpatch.c -o ${PATCH_LIB}/dngpatch.o

${PATCH_LIB}/u5data.o: u5data.c u5patch.h ${COMMON_HEADERS}
	${CC} u5data.c -o ${PATCH_LIB}/u5data.o

${PATCH_LIB}/patch.o: patch.c ${COMMON_HEADERS}
	${CC} patch.c -o ${PATCH_LIB}/patch.o

# binary files
${U2BIN}/cgapatch: ${COMMON_LIB}/File.o ${PATCH_LIB}/cgapatch.o
	${LD} -o ${U2BIN}/cgapatch ${COMMON_LIB}/File.o ${PATCH_LIB}/cgapatch.o

${U2BIN}/dngpatch: ${COMMON_LIB}/File.o ${PATCH_LIB}/dngpatch.o
	${LD} -o ${U2BIN}/dngpatch ${COMMON_LIB}/File.o ${PATCH_LIB}/dngpatch.o

${U5BIN}/u5data: ${COMMON_LIB}/File.o ${PATCH_LIB}/u5data.o ${PATCH_LIB}/patch.o
	${LD} -o ${U5BIN}/u5data ${COMMON_LIB}/File.o ${PATCH_LIB}/u5data.o ${PATCH_LIB}/patch.o

# clean
clean:
	rm ${PATCH_LIB}/*.o
	rm ${U2BIN}/cgapatch
	rm ${U2BIN}/dngpatch
	rm ${U5BIN}/u5data
