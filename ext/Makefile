# directories
ROOT = ..
include ${ROOT}/Makefile.include

all: package

### package build targets ###

package: package_u2 package_u3 package_u5

package_u2:
	### No DMKit for U2

package_u3: ${DMKIT}
	### Packaging DMKit for U3
	cp -f ${DMKIT}/*.ADV ${DMKIT}/*.ADD ${DMKIT}/*MIDPAK.COM ${DMKIT}/SETM.EXE ${DMKIT}/SETM.XMI ${DMKIT}/FAT.OPL ${U3PKG}

package_u5: ${DMKIT}
	### Packaging DMKit for U5
	cp -f ${DMKIT}/*.ADV ${DMKIT}/*.ADD ${DMKIT}/*MIDPAK.COM ${DMKIT}/SETM.EXE ${DMKIT}/SETM.XMI ${DMKIT}/FAT.OPL ${U5PKG}

${DMKIT}: ${EXT}/dmkit-1.50.zip
	mkdir -p ${DMKIT}
	${UNZIP} ${EXT}/dmkit-1.50.zip -d ${DMKIT}
