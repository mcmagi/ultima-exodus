# directories
DIRS = color launcher u3drv u5drv

compile:
	for i in ${DIRS}; do \
		cd $$i && $(MAKE) compile; \
		cd ..; \
	done

package:
	for i in ${DIRS}; do \
		cd $$i && $(MAKE) package; \
		cd ..; \
	done

clean:
	for i in ${DIRS}; do \
		cd $$i && $(MAKE) clean; \
		cd ..; \
	done
