ROOT=../..
include ${ROOT}/Makefile.include

compile: ${COMMON_LIB}/File.o ${COMMON_LIB}/DirList.o ${COMMON_LIB}/option.o \
		${COMMON_LIB}/IniCfg.o ${COMMON_LIB}/stringutil.o ${COMMON_LIB}/filepath.o \
		${COMMON_LIB}/List.o ${COMMON_LIB}/debug.o

${COMMON_LIB}:
	mkdir -p ${COMMON_LIB}

# object files
${COMMON_LIB}/File.o: File.c File.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/File.o, File.c)

${COMMON_LIB}/DirList.o: DirList.c DirList.h File.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/DirList.o, DirList.c)

${COMMON_LIB}/option.o: option.c option.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/option.o, option.c)

${COMMON_LIB}/IniCfg.o: IniCfg.c IniCfg.h File.h gendefs.h stringutil.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/IniCfg.o, IniCfg.c)

${COMMON_LIB}/stringutil.o: stringutil.c stringutil.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/stringutil.o, stringutil.c)

${COMMON_LIB}/filepath.o: filepath.c filepath.h stringutil.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/filepath.o, filepath.c)

${COMMON_LIB}/List.o: List.c List.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/List.o, List.c)

${COMMON_LIB}/debug.o: debug.c debug.h gendefs.h | ${COMMON_LIB}
	$(call compile, ${COMMON_LIB}/debug.o, debug.c)

# clean
clean:
	rm ${COMMON_LIB}/*.o
