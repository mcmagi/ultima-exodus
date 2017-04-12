ROOT=../..
include ${ROOT}/Makefile.include

compile: ${COMMON_LIB}/File.o ${COMMON_LIB}/DirList.o

${COMMON_LIB}:
	mkdir -p ${COMMON_LIB}

# object files
${COMMON_LIB}/File.o: File.c File.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/File.o, File.c)

${COMMON_LIB}/DirList.o: DirList.c DirList.h File.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/DirList.o, DirList.c)

# clean
clean:
	rm ${COMMON_LIB}/*.o
