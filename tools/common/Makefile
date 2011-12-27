ROOT=../..
include ${ROOT}/Makefile.include

all: mkdirs ${COMMON_LIB}/File.o

mkdirs: ${COMMON_LIB}

${COMMON_LIB}:
	mkdir -p ${COMMON_LIB}

# object files
${COMMON_LIB}/File.o: File.h gendefs.h
	${CC} -c File.c -o ${COMMON_LIB}/File.o

# clean
clean:
	rm ${COMMON_LIB}/File.o
