# directories
DIRS = common cfg patch reset tlk binpatch

all:
	for i in ${DIRS}; do \
		cd $$i && $(MAKE); \
		cd ..; \
	done

clean:
	for i in ${DIRS}; do \
		cd $$i && $(MAKE) clean; \
		cd ..; \
	done
