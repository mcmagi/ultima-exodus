ROOT=../..
include ${ROOT}/Makefile.${TARGET}.include

all: mkdirs ${U2BIN}/u2cfg ${U3BIN}/u3cfg ${U5BIN}/u5cfg

mkdirs: ${CFG_LIB} ${U2BIN} ${U3BIN} ${U5BIN}

${CFG_LIB}:
	mkdir -p ${CFG_LIB}

# object files
${CFG_LIB}/u2cfg.o: u2cfg.c u2cfg.h cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h
	$(call compile, ${CFG_LIB}/u2cfg.o, u2cfg.c)

${CFG_LIB}/u3cfg.o: u3cfg.c u3cfg.h cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h
	$(call compile, ${CFG_LIB}/u3cfg.o, u3cfg.c)

${CFG_LIB}/u5cfg.o: u5cfg.c u5cfg.h cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h
	$(call compile, ${CFG_LIB}/u5cfg.o, u5cfg.c)

${CFG_LIB}/status.o: status.c cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h
	$(call compile, ${CFG_LIB}/status.o, status.c)

# binary files
${U2BIN}/u2cfg: ${CFG_LIB}/u2cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o
	$(call link, ${U2BIN}/u2cfg, ${CFG_LIB}/u2cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o)

${U3BIN}/u3cfg: ${CFG_LIB}/u3cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o
	$(call link, ${U3BIN}/u3cfg, ${CFG_LIB}/u3cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o)

${U5BIN}/u5cfg: ${CFG_LIB}/u5cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o
	$(call link, ${U5BIN}/u5cfg, ${CFG_LIB}/u5cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o)

# clean
clean:
	rm ${CFG_LIB}/*.o
	rm ${U2BIN}/u2cfg
	rm ${U3BIN}/u3cfg
	rm ${U5BIN}/u5cfg
