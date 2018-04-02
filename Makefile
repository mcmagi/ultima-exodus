# directories
ROOT = .
include ${ROOT}/Makefile.include

.PHONY := all clean fullclean compile package install

all: compile package install

compile:
	make -C ${TOOLS} compile
	make -C ${ASMSRC} compile

clean:
	make -C ${TOOLS} clean
	make -C ${ASMSRC} clean
	make package_clean

fullclean:
	rm -rf ${BUILD}

### patch build targets ###

patch_u2:
	make -C ${PATCHES} patch_u2

patch_u3:
	make -C ${PATCHES} patch_u3

patch_u5:
	make -C ${PATCHES} patch_u5

apply_patch_u2:
	make -C ${PATCHES} apply_patch_u2

apply_patch_u3:
	make -C ${PATCHES} apply_patch_u3

apply_patch_u5:
	make -C ${PATCHES} apply_patch_u5

### package build targets ###

PACKAGE_DIRS = ${TOOLS} ${ASMSRC} ${DATA} ${PATCHES} ${DOC} ${EXT}

package: package_u2 package_u3 package_u5

package_u2: package_clean_u2 ${U2PKG_ZIP}

package_u3: package_clean_u3 ${U3PKG_ZIP}

package_u5: package_clean_u5 ${U5PKG_ZIP}

package_clean: package_clean_u2 package_clean_u3 package_clean_u5

package_clean_u2:
	rm -rf ${U2PKG} ${U2PKG_ZIP}

package_clean_u3:
	rm -rf ${U3PKG} ${U3PKG_ZIP}

package_clean_u5:
	rm -rf ${U5PKG} ${U5PKG_ZIP}

${U2PKG}:
	### packaging U2 Upgrade files
	mkdir -p ${U2PKG}
	for i in ${PACKAGE_DIRS}; do \
		if [ -d "$$i" ]; then \
			make -C "$$i" package_u2; \
		fi \
	done
	make -C "${TOOLS}" gen_config_u2

${U3PKG}:
	### packaging U3 Upgrade files
	mkdir -p ${U3PKG}
	for i in ${PACKAGE_DIRS}; do \
		if [ -d "$$i" ]; then \
			make -C "$$i" package_u3; \
		fi \
	done; \
	make -C "${TOOLS}" gen_config_u3

${U5PKG}:
	### packaging U5 Upgrade files
	mkdir -p ${U5PKG}
	for i in ${PACKAGE_DIRS}; do \
		if [ -d "$$i" ]; then \
			make -C "$$i" package_u5; \
		fi \
	done

${U2PKG_ZIP}: ${U2PKG}
	### creating U2 Upgrade zip
	pushd ${U2PKG}; ${ZIP} -r ../../${U2PKG_ZIP} .; popd

${U3PKG_ZIP}: ${U3PKG}
	### creating U3 Upgrade zip
	pushd ${U3PKG}; ${ZIP} -r ../../${U3PKG_ZIP} .; popd

${U5PKG_ZIP}: ${U5PKG}
	### creating U5 Upgrade zip
	pushd ${U5PKG}; ${ZIP} -r ../../${U5PKG_ZIP} .; popd

### install build targets ###

install: install_u2 install_u3 install_u5

install_u2: ${U2UPGRADE}
	### Installing U2 upgrade
	cp -Rf ${U2PKG}/* ${U2UPGRADE}

install_u3: ${U3UPGRADE}
	### Installing U3 upgrade
	cp -Rf ${U3PKG}/* ${U3UPGRADE}

install_u5: ${U5UPGRADE}
	### Installing U5 upgrade
	cp -Rf ${U5PKG}/* ${U5UPGRADE}

${U2UPGRADE}:
	cp -a ${U2ORIGINAL} ${U2UPGRADE}
	make apply_patch_u2

${U3UPGRADE}:
	cp -a ${U3ORIGINAL} ${U3UPGRADE}
	make apply_patch_u3

${U5UPGRADE}:
	cp -a ${U5ORIGINAL} ${U5UPGRADE}
	make apply_patch_u5
