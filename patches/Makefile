# directories
ROOT = ..
include ${ROOT}/Makefile.include

# patch filenames
U2PAT = ${PATCHES}/u2up-$(call stripdots,${U2VER}).pat
U3PAT = ${PATCHES}/u3up-$(call stripdots,${U3VER}).pat
U5PAT = ${PATCHES}/u5up-$(call stripdots,${U5VER}).pat

all: package

clean:
	rm -f ${U2PAT} ${U3PAT} ${U5PAT}

### patch build targets ###

patch: ${U2PAT} ${U3PAT} ${U5PAT}

patch_u2: ${U2PAT}

patch_u3: ${U3PAT}

patch_u5: ${U5PAT}

${U2PAT}: ${U2UPGRADE}/ULTIMAII.EXE ${U2UPGRADE}/MAPX10 ${U2UPGRADE}/MAPX15
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
		${DIFF} -a add -nd ${U2UPGRADE} -n MAPG$${i} -p ${U2PAT}; \
	done
	# add missing galaxy talk files
	for i in 32 41; do \
		${DIFF} -a add -nd ${U2UPGRADE} -n TLKG$${i} -p ${U2PAT}; \
		${DIFF} -a add -nd ${U2UPGRADE} -n TLKG$${i} -p ${U2PAT}; \
	done

${U3PAT}: ${U3UPGRADE}/ULTIMA.COM ${U3UPGRADE}/BOOTUP.BIN ${U3UPGRADE}/EXODUS.BIN ${U3UPGRADE}/DUNGEON.DAT
	rm -f ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U2UPGRADE} -o ULTIMA.COM -n ULTIMA.COM -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U2UPGRADE} -o BOOTUP.BIN -n BOOTUP.BIN -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U2UPGRADE} -o EXODUS.BIN -n EXODUS.BIN -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -nd ${U2UPGRADE} -o DUNGEON.DAT -n DUNGEON.DAT -p ${U3PAT}

${U5PAT}: ${U5UPGRADE}/ULTIMA.EXE ${U5UPGRADE}/INTRO.OVL ${U5UPGRADE}/MAINOUT.OVL ${U5UPGRADE}/TOWN.OVL \
        ${U5UPGRADE}/DUNGEON.OVL ${U5UPGRADE}/ENDGAME.OVL ${U5UPGRADE}/FONT.OVL ${U5UPGRADE}/DATA.OVL
	rm -f ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o ULTIMA.EXE -n ULTIMA.EXE -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o INTRO.OVL -n INTRO.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o MAINOUT.OVL -n MAINOUT.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o TOWN.OVL -n TOWN.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o DUNGEON.OVL -n DUNGEON.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o ENDGAME.OVL -n ENDGAME.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o FONT.OVL -n FONT.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -nd ${U2UPGRADE} -o DATA.OVL -n DATA.OVL -p ${U5PAT}

### package build targets ###

package: package_u2 package_u3 package_u5

package_u2: ${U2PAT}
	echo "Packaging Patches for U2"
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
