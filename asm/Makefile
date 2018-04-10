# directories
DIRS = color launcher u2drv u3drv u5drv u3mod test


%: FORCE
	for i in ${DIRS}; do \
		cd $$i; \
		echo "asm/$$i $@:"; $(MAKE) $@ || exit 1; \
		cd ..; \
	done

package_u2: FORCE
	make -C launcher $@
	make -C u2drv $@

package_u3: FORCE
	make -C launcher $@
	make -C u3drv $@
	make -C u3mod $@

package_u5: FORCE
	make -C launcher $@
	make -C u5drv $@

Makefile: ;
FORCE: ;