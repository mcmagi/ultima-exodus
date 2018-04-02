# directories
ROOT = ..
include ${ROOT}/Makefile.include

# patch filenames
U2PATGOG = ${PATCHES}/u2-gog.pat
U2PAT = ${PATCHES}/u2up-$(call stripdots,${U2VER}).pat
U3PAT = ${PATCHES}/u3up-$(call stripdots,${U3VER}).pat
U5PAT = ${PATCHES}/u5up-$(call stripdots,${U5VER}).pat

all: package

clean:
	rm -f ${U2PAT} ${U3PAT} ${U5PAT}

### patch build targets ###

patch: ${U2PAT} ${U3PAT} ${U5PAT}

patch_u2: ${U2PATGOG} ${U2PAT}

patch_u3: ${U3PAT}

patch_u5: ${U5PAT}

${U2PATGOG}:
	rm -f ${U2PATGOG}
	${DIFF} -od ${U2ORIGINAL} -nd ${U2GOG} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PATGOG}
	# patch greenland dungeon
	${DIFF} -od ${U2ORIGINAL} -nd ${U2GOG} -o MAPX10 -n MAPX10 -p ${U2PATGOG}
	${DIFF} -od ${U2ORIGINAL} -nd ${U2GOG} -o MAPX15 -n MAPX15 -p ${U2PATGOG}
	# patch earth talk files
	for i in 03 11 21 22 23 31 32 33 41; do \
		${DIFF} -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o TLKX$${i} -n TLKX$${i} -p ${U2PATGOG}; \
	done
	# rename existing galaxy map & monster files
	for i in 44 50 60 61 70 71 80 81 82 85 90 92 93; do \
		${DIFF} -a rename -od ${U2ORIGINAL} -nd ${U2GOG} -o MAPX$${i} -n mapg$${i} -p ${U2PATGOG}; \
		${DIFF} -a rename -od ${U2ORIGINAL} -nd ${U2GOG} -o MONX$${i} -n mong$${i} -p ${U2PATGOG}; \
	done
	# rename & patch existing galaxy talk files
	for i in 61 71 81 82 92 93; do \
		${DIFF} -a rename -od ${U2ORIGINAL} -nd ${U2GOG} -o TLKX$${i} -n TLKG$${i} -p ${U2PATGOG}; \
	done
	# add missing galaxy map & monster files
	for i in 10 15 30 40 45; do \
		${DIFF} -a add -nd ${U2GOG} -n MAPG$${i} -p ${U2PATGOG}; \
		${DIFF} -a add -nd ${U2GOG} -n mong$${i} -p ${U2PATGOG}; \
	done
	for i in 20 32 41; do \
		${DIFF} -a add -nd ${U2GOG} -n MAPG$${i} -p ${U2PATGOG}; \
		${DIFF} -a add -nd ${U2GOG} -n MONG$${i} -p ${U2PATGOG}; \
	done
	# add missing galaxy talk files
	for i in 32 41; do \
		${DIFF} -a add -nd ${U2GOG} -n TLKG$${i} -p ${U2PATGOG}; \
	done

${U2PAT}:
	rm -f ${U2PAT}
	${DIFF} -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PAT}
	# patch greenland dungeon
	${DIFF} -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o MAPX10 -n MAPX10 -p ${U2PAT}
	${DIFF} -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o MAPX15 -n MAPX15 -p ${U2PAT}
	# patch earth talk files
	for i in 03 11 21 22 23 31 32 33 41; do \
		${DIFF} -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o TLKX$${i} -n TLKX$${i} -p ${U2PAT}; \
	done
	# rename existing galaxy map & monster files
	for i in 44 50 60 61 70 71 80 81 82 85 90 92 93; do \
		${DIFF} -a rename -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o MAPX$${i} -n MAPG$${i} -p ${U2PAT}; \
		${DIFF} -a rename -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o MONX$${i} -n MONG$${i} -p ${U2PAT}; \
	done
	# rename & patch existing galaxy talk files
	for i in 61 71 81 82 92 93; do \
		${DIFF} -a rename -od ${U2ORIGINAL} -nd ${U2UPGRADE} -o TLKX$${i} -n TLKG$${i} -p ${U2PAT}; \
	done
	# add missing galaxy map & monster files
	for i in 10 15 20 30 32 40 41 45; do \
		${DIFF} -a add -nd ${U2UPGRADE} -n MAPG$${i} -p ${U2PAT}; \
		${DIFF} -a add -nd ${U2UPGRADE} -n MONG$${i} -p ${U2PAT}; \
	done
	# add missing galaxy talk files
	for i in 32 41; do \
		${DIFF} -a add -nd ${U2UPGRADE} -n TLKG$${i} -p ${U2PAT}; \
	done

${U3PAT}:
	rm -f ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U3UPGRADE} -o ULTIMA.COM -n ULTIMA.COM -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U3UPGRADE} -o BOOTUP.BIN -n BOOTUP.BIN -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U3UPGRADE} -o EXODUS.BIN -n EXODUS.BIN -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U3UPGRADE} -o DUNGEON.DAT -n DUNGEON.DAT -p ${U3PAT}

${U5PAT}:
	rm -f ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o ULTIMA.EXE -n ULTIMA.EXE -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o INTRO.OVL -n INTRO.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o MAINOUT.OVL -n MAINOUT.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o TOWN.OVL -n TOWN.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o DUNGEON.OVL -n DUNGEON.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o ENDGAME.OVL -n ENDGAME.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o FONT.OVL -n FONT.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U5UPGRADE} -o DATA.OVL -n DATA.OVL -p ${U5PAT}

### package build targets ###

package: package_u2 package_u3 package_u5

package_u2: ${U2PAT}
	echo "Packaging Patches for U2"
	cp -f ${U2PATGOG} ${U2PKG}
	cp -f ${U2PAT} ${U2PKG}

package_u3: ${U3PAT}
	echo "Packaging Patches for U3"
	cp -f ${U3PAT} ${U3PKG}

package_u5: ${U5PAT}
	echo "Packaging Patches for U5"
	cp -f ${U5PAT} ${U5PKG}


### apply patch targets ###

apply_patch: apply_patch_u2 apply_patch_u3 apply_patch_u5

apply_patch_u2:
	${PATCH} -d ${U2UPGRADE} ${U2PAT}

apply_patch_u3:
	${PATCH} -d ${U3UPGRADE} ${U3PAT}

apply_patch_u5:
	${PATCH} -d ${U5UPGRADE} ${U5PAT}
