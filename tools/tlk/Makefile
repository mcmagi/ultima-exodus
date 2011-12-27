# Makefile for TLK proggies
ROOT=../..
include ${ROOT}/Makefile.include


all: mkdirs ${U2BIN}/viewtlk

mkdirs: ${TLK_LIB} ${U2BIN}

${TLK_LIB}:
	mkdir -p ${TLK_LIB}


# object files
${TLK_LIB}/tlkio.o: tlkio.c tlklib.h
	${CC} tlkio.c -o ${TLK_LIB}/tlkio.o

${TLK_LIB}/tlklib.o: tlklib.c tlklib.h
	${CC} tlklib.c -o ${TLK_LIB}/tlklib.o

${TLK_LIB}/tlkfile.o: tlkfile.c tlklib.h ${COMMON}/File.h
	${CC} tlkfile.c -o ${TLK_LIB}/tlkfile.o

${TLK_LIB}/viewtlk.o: viewtlk.c viewtlk.h ${COMMON}/File.h
	${CC} viewtlk.c -o ${TLK_LIB}/viewtlk.o


# library files
${TLK_LIB}/tlklib.a: ${TLK_LIB}/tlkfile.o ${TLK_LIB}/tlklib.o ${TLK_LIB}/tlkio.o
	${AR} -r ${TLK_LIB}/tlklib.a ${TLK_LIB}/tlkfile.o ${TLK_LIB}/tlklib.o \
		${TLK_LIB}/tlkio.o


# binary files
${U2BIN}/viewtlk: ${TLK_LIB}/viewtlk.o ${TLK_LIB}/tlklib.a ${COMMON_LIB}/File.o
	${LD} ${TLK_LIB}/viewtlk.o ${TLK_LIB}/tlklib.a ${COMMON_LIB}/File.o \
		-o ${U2BIN}/viewtlk

# clean
clean:
	rm ${TLK_LIB}/*.[oa]
	rm ${U2BIN}/viewtlk
