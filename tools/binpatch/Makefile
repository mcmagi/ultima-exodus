ROOT=../..
include ${ROOT}/Makefile.include

HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h bindiff.h patchadd.h patch.h

all: mkdirs ${UTILBIN}/bindiff ${UTILBIN}/binpatch

mkdirs: ${BINPATCH_LIB} ${UTILBIN}

${BINPATCH_LIB}:
	mkdir -p ${BINPATCH_LIB}

# object files
${BINPATCH_LIB}/bindiff.o: bindiff.c ${HEADERS}
	${CC} bindiff.c -o ${BINPATCH_LIB}/bindiff.o

${BINPATCH_LIB}/binpatch.o: binpatch.c ${HEADERS}
	${CC} binpatch.c -o ${BINPATCH_LIB}/binpatch.o

${BINPATCH_LIB}/patch.o: patch.c patch.h
	${CC} patch.c -o ${BINPATCH_LIB}/patch.o

${BINPATCH_LIB}/patchadd.o: patchadd.c ${HEADERS}
	${CC} patchadd.c -o ${BINPATCH_LIB}/patchadd.o

# binary files
${UTILBIN}/binpatch: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o ${BINPATCH_LIB}/patch.o
	${LD} -o ${UTILBIN}/binpatch ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o \
		${BINPATCH_LIB}/patch.o

${UTILBIN}/bindiff: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchadd.o
	${LD} -o ${UTILBIN}/bindiff ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchadd.o

# clean
clean:
	rm ${BINPATCH_LIB}/*.o
	rm ${UTILBIN}/bindiff
	rm ${UTILBIN}/binpatch
