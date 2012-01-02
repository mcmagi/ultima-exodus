# Makefile for TLK proggies
ROOT=../..
include ${ROOT}/Makefile.include


compile: mkdirs ${U2BIN}/viewtlk

mkdirs: ${TLK_LIB} ${U2BIN}

${TLK_LIB}:
	mkdir -p ${TLK_LIB}


# object files
${TLK_LIB}/tlkio.o: tlkio.c tlklib.h
	$(call compile, ${TLK_LIB}/tlkio.o, tlkio.c)

${TLK_LIB}/tlklib.o: tlklib.c tlklib.h
	$(call compile, ${TLK_LIB}/tlklib.o, tlklib.c)

${TLK_LIB}/tlkfile.o: tlkfile.c tlklib.h ${COMMON}/File.h
	$(call compile, ${TLK_LIB}/tlkfile.o, tlkfile.c)

${TLK_LIB}/viewtlk.o: viewtlk.c viewtlk.h ${COMMON}/File.h
	$(call compile, ${TLK_LIB}/viewtlk.o, viewtlk.c)


# library files
${TLK_LIB}/tlklib.a: ${TLK_LIB}/tlkfile.o ${TLK_LIB}/tlklib.o ${TLK_LIB}/tlkio.o
	$(call archive, ${TLK_LIB}/tlklib.a, ${TLK_LIB}/tlkfile.o ${TLK_LIB}/tlklib.o \
		${TLK_LIB}/tlkio.o)


# binary files
${U2BIN}/viewtlk: ${TLK_LIB}/viewtlk.o ${TLK_LIB}/tlklib.a ${COMMON_LIB}/File.o
	$(call link, ${U2BIN}/viewtlk, ${TLK_LIB}/viewtlk.o ${TLK_LIB}/tlklib.a ${COMMON_LIB}/File.o)

# clean
clean:
	rm ${TLK_LIB}/*.[oa]
	rm ${U2BIN}/viewtlk
