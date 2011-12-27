ROOT=../..
include ${ROOT}/Makefile.${TARGET}.include

all: mkdirs ${COMMON_LIB}/File.o

mkdirs: ${COMMON_LIB}

${COMMON_LIB}:
	mkdir -p ${COMMON_LIB}

# object files
${COMMON_LIB}/File.o: File.c File.h gendefs.h
	$(call compile, ${COMMON_LIB}/File.o, File.c)

# clean
clean:
	rm ${COMMON_LIB}/File.o
