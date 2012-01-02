# directories
DIRS = common cfg patch reset tlk binpatch

compile:
	# construct both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE) compile; \
			TARGET=dos $(MAKE) compile; \
			cd ..; \
		fi \
	done

package:
	# package only dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=dos $(MAKE) package; \
			cd ..; \
		fi \
	done

clean:
	# clean both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE) clean; \
			TARGET=dos $(MAKE) clean; \
			cd ..; \
		fi \
	done
