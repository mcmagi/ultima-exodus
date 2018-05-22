# directories
DIRS = color launcher u2drv u3drv u5drv u3mod test


%: FORCE
	for i in ${DIRS}; do \
		if [ -d "$$i" ]; then \
			make -C $$i $@ || exit 1; \
		fi \
	done || exit 1

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