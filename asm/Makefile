# directories
DIRS = color launcher u3drv u5drv


%: FORCE
	for i in ${DIRS}; do \
		cd $$i && $(MAKE) $@ || (echo "asm/$$i $@ failed"; exit 1); \
		cd ..; \
	done

Makefile: ;
FORCE: ;