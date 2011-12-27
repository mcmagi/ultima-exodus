# directories
DIRS = common cfg patch reset tlk binpatch

all:
	# construct both local and dos targets
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			cd $$i; \
			TARGET=local $(MAKE); \
			TARGET=dos $(MAKE); \
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
