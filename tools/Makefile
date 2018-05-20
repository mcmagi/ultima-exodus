# directories
DIRS = common cfg patch reset tlk binpatch
PACKAGE_DIRS = cfg binpatch

%: FORCE
	# operate on both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			TARGET=local make -C $$i $@ || exit 1; \
			TARGET=dos make -C $$i $@ || exit 1; \
			TARGET=winnt make -C $$i $@ || exit 1; \
			TARGET=linux make -C $$i $@ || exit 1; \
		fi \
	done || exit 1

package%: FORCE
	# package only dos/win/linux targets
	for i in ${PACKAGE_DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=dos make -C $$i $@ || exit 1; \
			TARGET=winnt make -C $$i $@ || exit 1; \
			TARGET=linux make -C $$i $@ || exit 1; \
			cd ..; \
		fi \
	done

gen_config%: FORCE
	# run local target to generate config file
	cd cfg; \
	TARGET=local make -C $$i $@ || exit 1; \
	cd ..

Makefile: ;
FORCE: ;