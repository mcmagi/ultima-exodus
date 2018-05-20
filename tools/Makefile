# directories
DIRS = common cfg patch reset tlk binpatch
PACKAGE_DIRS = cfg binpatch

%: FORCE
	# operate on both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			TARGET=dos $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			TARGET=winnt $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			TARGET=linux $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			cd ..; \
		fi \
	done

package%: FORCE
	# package only dos/win/linux targets
	for i in ${PACKAGE_DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=dos $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			TARGET=winnt $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			TARGET=linux $(MAKE) $@ || (echo "tools/$$i $@ ${TARGET} failed"; exit 1); \
			cd ..; \
		fi \
	done

gen_config%: FORCE
	# run local target to generate config file
	cd cfg; \
	TARGET=local $(MAKE) $@ || (echo "tools/cfg $@ ${TARGET} failed"; exit 1); \
	cd ..

Makefile: ;
FORCE: ;