# directories
DIRS = common cfg patch reset tlk binpatch

%: FORCE
	# operate on both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			TARGET=dos $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			TARGET=winnt $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			TARGET=linux $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			cd ..; \
		fi \
	done

package%: FORCE
	# package only dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=dos $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			TARGET=winnt $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			TARGET=linux $(MAKE) $@ || (echo "build ${TARGET} failed"; exit 1); \
			cd ..; \
		fi \
	done

Makefile: ;
FORCE: ;