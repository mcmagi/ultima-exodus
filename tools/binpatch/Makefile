ROOT=../..
include ${ROOT}/Makefile.${TARGET}.include

HEADERS=${COMMON}/File.h ${COMMON}/gendefs.h bindiff.h patchadd.h patch.h

all: mkdirs ${UTILBIN}/bindiff ${UTILBIN}/binpatch

mkdirs: ${BINPATCH_LIB} ${UTILBIN}

${BINPATCH_LIB}:
	mkdir -p ${BINPATCH_LIB}

# object files
${BINPATCH_LIB}/bindiff.o: bindiff.c ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/bindiff.o, bindiff.c)

${BINPATCH_LIB}/binpatch.o: binpatch.c ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/binpatch.o, binpatch.c)

${BINPATCH_LIB}/patch.o: patch.c patch.h
	$(call compile, ${BINPATCH_LIB}/patch.o, patch.c)

${BINPATCH_LIB}/patchadd.o: patchadd.c ${HEADERS}
	$(call compile, ${BINPATCH_LIB}/patchadd.o, patchadd.c)

# binary files
${UTILBIN}/binpatch: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o ${BINPATCH_LIB}/patch.o
	$(call link, ${UTILBIN}/binpatch, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/binpatch.o \
		${BINPATCH_LIB}/patch.o)

${UTILBIN}/bindiff: ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o ${BINPATCH_LIB}/patch.o \
		${BINPATCH_LIB}/patchadd.o
	$(call link, ${UTILBIN}/bindiff, ${COMMON_LIB}/File.o ${BINPATCH_LIB}/bindiff.o \
		${BINPATCH_LIB}/patch.o ${BINPATCH_LIB}/patchadd.o)

# clean
clean:
	rm ${BINPATCH_LIB}/*.o
	rm ${UTILBIN}/bindiff
	rm ${UTILBIN}/binpatch
