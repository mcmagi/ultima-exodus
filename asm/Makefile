# directories
DIRS = color launcher u3drv u5drv u3mod


%: FORCE
	for i in ${DIRS}; do \
		cd $$i; \
		echo "asm/$$i $@:"; $(MAKE) $@ || exit 1; \
		cd ..; \
	done

Makefile: ;
FORCE: ;