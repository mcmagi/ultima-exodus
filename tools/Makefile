# directories
DIRS = common cfg patch reset tlk binpatch

%: FORCE
	# operate on both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE) $@; \
			TARGET=dos $(MAKE) $@; \
			TARGET=winnt $(MAKE) $@; \
			TARGET=linux $(MAKE) $@; \
			cd ..; \
		fi \
	done

package%: FORCE
	# package only dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=dos $(MAKE) $@; \
			TARGET=winnt $(MAKE) $@; \
			TARGET=linux $(MAKE) $@; \
			cd ..; \
		fi \
	done

Makefile: ;
FORCE: ;