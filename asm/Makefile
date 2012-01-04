# directories
DIRS = color launcher u3drv u5drv


%: FORCE
	for i in ${DIRS}; do \
		cd $$i && $(MAKE) $@; \
		cd ..; \
	done

Makefile: ;
FORCE: ;