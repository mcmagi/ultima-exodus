# directories
ROOT = ..
include ${ROOT}/Makefile.include

all: package

### package build targets ###

package: package_u2 package_u3 package_u5

package_u2: ${U2PKG}
	echo "Packaging Data for U2"
	cp -f ${DATA}/u2gfx/* ${U2PKG}
	#cp -f ${DATA}/u2tlk/* ${U2PKG}
	#cp -f ${DATA}/u2gal/* ${U2PKG}

package_u3: ${U3PKG}
	echo "Packaging Data for U3"
	cp -f ${DATA}/u3gfx/* ${U3PKG}
	cp -f ${DATA}/u3midi/* ${U3PKG}
	cp -fR ${DATA}/u3mod/* ${U3PKG}

package_u5: ${U5PKG}
	echo "Packaging Data for U5"
	cp -f ${DATA}/u5midi/* ${U5PKG}
