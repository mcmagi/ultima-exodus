# directories
DIRS = common cfg patch reset tlk binpatch

%: FORCE
	# operate on both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			TARGET=dos $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			TARGET=winnt $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			TARGET=linux $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			cd ..; \
		fi \
	done

package%: FORCE
	# package only dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=dos $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			TARGET=winnt $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			TARGET=linux $(MAKE) $@ || (echo "tools/$$i build ${TARGET} failed"; exit 1); \
			cd ..; \
		fi \
	done

Makefile: ;
FORCE: ;