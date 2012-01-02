# directories
ROOT = .
include ${ROOT}/Makefile.include

all: compile package install

compile:
	make -C ${TOOLS} compile
	make -C ${ASMSRC} compile

clean:
	make -C ${TOOLS} clean
	make -C ${ASMSRC} clean
	rm -rf ${BUILD}

### patch build targets ###

patch:
	make -C ${PATCHES} patch

patch_u2:
	make -C ${PATCHES} patch_u2

patch_u3:
	make -C ${PATCHES} patch_u3

patch_u5:
	make -C ${PATCHES} patch_u5

### package build targets ###

PACKAGE_DIRS = ${TOOLS} ${ASMSRC} ${DATA} ${PATCHES} ${DOC} ${EXT}

package: package_clean ${U2PKG} ${U3PKG} ${U5PKG}
	for i in ${PACKAGE_DIRS}; do \
		if [ -d "$$i" ]; then \
			make -C "$$i" package; \
		fi \
	done
	echo "Creating package ZIP files"
	make ${U2PKG_ZIP}
	make ${U3PKG_ZIP}
	make ${U5PKG_ZIP}

package_clean:
	rm -rf ${U2PKG} ${U3PKG} ${U5PKG}
	rm -f ${U2PKG_ZIP} ${U3PKG_ZIP} ${U5PKG_ZIP}

${U2PKG_ZIP}: ${U2PKG}
	${ZIP} ${U2PKG_ZIP} ${U2PKG}/*

${U3PKG_ZIP}: ${U3PKG}
	${ZIP} ${U3PKG_ZIP} ${U3PKG}/*

${U5PKG_ZIP}: ${U5PKG}
	${ZIP} ${U5PKG_ZIP} ${U5PKG}/*

### install build targets ###

install: install_u2 install_u3 install_u5

install_u2:
	echo "Installing U2 upgrade"
	cp -f ${U2PKG}/* ${U2UPGRADE}

install_u3:
	echo "Installing U3 upgrade"
	cp -f ${U3PKG}/* ${U3UPGRADE}

install_u5:
	echo "Installing U5 upgrade"
	cp -f ${U5PKG}/* ${U5UPGRADE}
