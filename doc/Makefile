# directories
ROOT = ..
include ${ROOT}/Makefile.include

all: package

### package build targets ###

package: package_u2 package_u3 package_u5

package_u2: ${U2PKG}
	echo "Packaging Documentation for U2"
	cp -f ${DOC}/u2notes/* ${U2PKG}

package_u3: ${U3PKG}
	echo "Packaging Documentation for U3"
	cp -f ${DOC}/u3notes/* ${U3PKG}

package_u5: ${U5PKG}
	echo "Packaging Documentation for U5"
	cp -f ${DOC}/u5notes/* ${U5PKG}
