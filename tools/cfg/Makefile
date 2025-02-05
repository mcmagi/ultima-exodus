ROOT=../..
include ${ROOT}/Makefile.include

HEADERS=${COMMON}/File.h ${COMMON}/DirList.h ${COMMON}/gendefs.h ${COMMON}/option.h \
		${COMMON}/IniCfg.h ${COMMON}/filepath.h ${COMMON}/stringutil.h ${COMMON}/debug.h \
		${COMMON}/List.h cfg.h
LIBS=${COMMON_LIB}/File.o ${COMMON_LIB}/DirList.o ${COMMON_LIB}/option.o ${COMMON_LIB}/IniCfg.o \
		${COMMON_LIB}/filepath.o ${COMMON_LIB}/stringutil.o ${COMMON_LIB}/debug.o \
		${COMMON_LIB}/List.o

compile: ${U2BIN}/u2cfg ${U3BIN}/u3cfg ${U5BIN}/u5cfg

${CFG_LIB}:
	mkdir -p ${CFG_LIB}

# object files
${CFG_LIB}/u2cfg.o: u2cfg.c u2cfg.h ${HEADERS} | ${CFG_LIB}
	$(call compile, ${CFG_LIB}/u2cfg.o, u2cfg.c)

${CFG_LIB}/u3cfg.o: u3cfg.c u3cfg.h cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h ${COMMON}/option.h | ${CFG_LIB}
	$(call compile, ${CFG_LIB}/u3cfg.o, u3cfg.c)

${CFG_LIB}/u5cfg.o: u5cfg.c u5cfg.h cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h ${COMMON}/option.h | ${CFG_LIB}
	$(call compile, ${CFG_LIB}/u5cfg.o, u5cfg.c)

${CFG_LIB}/status.o: status.c cfg.h ${COMMON}/gendefs.h ${COMMON}/File.h | ${CFG_LIB}
	$(call compile, ${CFG_LIB}/status.o, status.c)

# binary files
${U2BIN}/u2cfg: ${CFG_LIB}/u2cfg.o ${CFG_LIB}/status.o ${LIBS} | ${U2BIN}
	$(call link, ${U2BIN}/u2cfg, ${CFG_LIB}/u2cfg.o ${CFG_LIB}/status.o ${LIBS})

${U3BIN}/u3cfg: ${CFG_LIB}/u3cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o ${COMMON_LIB}/option.o | ${U3BIN}
	$(call link, ${U3BIN}/u3cfg, ${CFG_LIB}/u3cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o ${COMMON_LIB}/option.o)

${U5BIN}/u5cfg: ${CFG_LIB}/u5cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o | ${U5BIN}
	$(call link, ${U5BIN}/u5cfg, ${CFG_LIB}/u5cfg.o ${CFG_LIB}/status.o ${COMMON_LIB}/File.o)

# clean
clean:
	rm ${CFG_LIB}/*.o
	rm ${U2BIN}/u2cfg
	rm ${U3BIN}/u3cfg
	rm ${U5BIN}/u5cfg

# package
package: package_u2 package_u3 package_u5

package_u2: ${U2BIN}/u2cfg
	cp -f ${U2BIN}/u2cfg ${U2PKG}/u2cfg${BINSUFFIX}

package_u3: ${U3BIN}/u3cfg
	cp -f ${U3BIN}/u3cfg ${U3PKG}/u3cfg${BINSUFFIX}

package_u5: ${U5BIN}/u5cfg
	cp -f ${U5BIN}/u5cfg ${U5PKG}/u5cfg${BINSUFFIX}

# generate default config file
gen_config_u2:
	cd ${U2PKG}; ${U2BIN}/u2cfg --gen-defaults
	
gen_config_u3:
	cd ${U3PKG}; ${U3BIN}/u3cfg --gen-defaults
	
gen_config_u5:
	