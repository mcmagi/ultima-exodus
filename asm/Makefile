# directories
DIRS = color launcher u3drv u5drv

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
