# directories
ROOT = .
include Makefile.include

all:
	make -C ${TOOLS}
	make -C ${ASMSRC}

clean:
	make -C ${TOOLS} clean
	make -C ${ASMSRC} clean

install:
	cp ${U2BIN}/* ${ULTIMA2}
	cp ${U3BIN}/* ${ULTIMA3}
	cp ${U5BIN}/* ${ULTIMA5}
