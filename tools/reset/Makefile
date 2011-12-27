# Makefile for reset proggies
ROOT=../..
include ${ROOT}/Makefile.include

all: mkdirs ${U2BIN}/u2reset ${U3BIN}/u3reset

mkdirs: ${RESET_LIB} ${U2BIN} ${U3BIN}

${RESET_LIB}:
	mkdir -p ${RESET_LIB}

# object files
${RESET_LIB}/fileutil.o: fileutil.c fileutil.h ${COMMON}/File.h
	${CC} fileutil.c -o ${RESET_LIB}/fileutil.o

${RESET_LIB}/u2reset.o: u2reset.c u2reset.h ${COMMON}/File.h
	${CC} u2reset.c -o ${RESET_LIB}/u2reset.o

${RESET_LIB}/u2tools.o: u2tools.c u2reset.h u2defs.h ${COMMON}/File.h
	${CC} u2tools.c -o ${RESET_LIB}/u2tools.o

${RESET_LIB}/u2predef.o: u2predef.c u2reset.h u2predef.h ${COMMON}/File.h
	${CC} u2predef.c -o ${RESET_LIB}/u2predef.o

${RESET_LIB}/u3reset.o: u3reset.c u3reset.h ${COMMON}/File.h
	${CC} u3reset.c -o ${RESET_LIB}/u3reset.o

${RESET_LIB}/u3tools.o: u3tools.c u3reset.h u3defs.h ${COMMON}/File.h
	${CC} u3tools.c -o ${RESET_LIB}/u3tools.o

# binary files
${U2BIN}/u2reset: ${RESET_LIB}/fileutil.o ${RESET_LIB}/u2reset.o \
		${RESET_LIB}/u2tools.o ${RESET_LIB}/u2predef.o ${COMMON_LIB}/File.o
	${LD} ${RESET_LIB}/fileutil.o ${RESET_LIB}/u2reset.o \
		${RESET_LIB}/u2tools.o ${RESET_LIB}/u2predef.o ${COMMON_LIB}/File.o \
		-o ${U2BIN}/u2reset

${U3BIN}/u3reset: ${RESET_LIB}/fileutil.o ${RESET_LIB}/u3reset.o \
		${RESET_LIB}/u3tools.o ${COMMON_LIB}/File.o
	${LD} ${RESET_LIB}/fileutil.o ${RESET_LIB}/u3reset.o \
		${RESET_LIB}/u3tools.o ${COMMON_LIB}/File.o \
		-o ${U3BIN}/u3reset

# clean
clean:
	rm ${U2BIN}/u2reset.exe
	rm ${U3BIN}/u3reset.exe
	rm ${RESET_LIB}/*.o
