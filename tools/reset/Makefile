# Makefile for reset proggies
ROOT=../..
include ${ROOT}/Makefile.include

compile: ${U2BIN}/u2reset ${U3BIN}/u3reset

${RESET_LIB}:
	mkdir -p ${RESET_LIB}

# object files
${RESET_LIB}/fileutil.o: fileutil.c fileutil.h ${COMMON}/File.h | ${RESET_LIB}
	$(call compile, ${RESET_LIB}/fileutil.o, fileutil.c)

${RESET_LIB}/u2reset.o: u2reset.c u2reset.h ${COMMON}/File.h | ${RESET_LIB}
	$(call compile, ${RESET_LIB}/u2reset.o, u2reset.c)

${RESET_LIB}/u2tools.o: u2tools.c u2reset.h u2defs.h ${COMMON}/File.h | ${RESET_LIB}
	$(call compile, ${RESET_LIB}/u2tools.o, u2tools.c)

${RESET_LIB}/u2predef.o: u2predef.c u2reset.h u2predef.h ${COMMON}/File.h | ${RESET_LIB}
	$(call compile, ${RESET_LIB}/u2predef.o, u2predef.c)

${RESET_LIB}/u3reset.o: u3reset.c u3reset.h ${COMMON}/File.h | ${RESET_LIB}
	$(call compile, ${RESET_LIB}/u3reset.o, u3reset.c)

${RESET_LIB}/u3tools.o: u3tools.c u3reset.h u3defs.h ${COMMON}/File.h | ${RESET_LIB}
	$(call compile, ${RESET_LIB}/u3tools.o, u3tools.c)

# binary files
${U2BIN}/u2reset: ${RESET_LIB}/fileutil.o ${RESET_LIB}/u2reset.o \
		${RESET_LIB}/u2tools.o ${RESET_LIB}/u2predef.o ${COMMON_LIB}/File.o | ${U2BIN}
	$(call link, ${U2BIN}/u2reset, ${RESET_LIB}/fileutil.o ${RESET_LIB}/u2reset.o \
		${RESET_LIB}/u2tools.o ${RESET_LIB}/u2predef.o ${COMMON_LIB}/File.o)

${U3BIN}/u3reset: ${RESET_LIB}/fileutil.o ${RESET_LIB}/u3reset.o \
		${RESET_LIB}/u3tools.o ${COMMON_LIB}/File.o | ${U3BIN}
	$(call link, ${U3BIN}/u3reset, ${RESET_LIB}/fileutil.o ${RESET_LIB}/u3reset.o \
		${RESET_LIB}/u3tools.o ${COMMON_LIB}/File.o)

# clean
clean:
	rm ${U2BIN}/u2reset
	rm ${U3BIN}/u3reset
	rm ${RESET_LIB}/*.o

# package
package: package_u2 package_u3

package_u2: ${U2PKG} ${U2BIN}/u2reset
	cp -f ${U2BIN}/u2reset ${U2PKG}

package_u3: ${U3PKG} ${U3BIN}/u3reset
	cp -f ${U3BIN}/u3reset ${U3PKG}
