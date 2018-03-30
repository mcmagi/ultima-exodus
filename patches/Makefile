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
	${DIFF} -od ${U2ORIGINAL} -o ULTIMAII.EXE -nd ${U2UPGRADE} -n ULTIMAII.EXE -p ${U2PAT}
	# patch greenland dungeon
	${DIFF} -od ${U2ORIGINAL} -o MAPX10 -nd ${U2UPGRADE} -n MAPX10 -p ${U2PAT}
	${DIFF} -od ${U2ORIGINAL} -o MAPX15 -nd ${U2UPGRADE} -n MAPX15 -p ${U2PAT}
	# rename map files
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX44 -nd ${U2UPGRADE} -n MAPG44 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX50 -nd ${U2UPGRADE} -n MAPG50 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX60 -nd ${U2UPGRADE} -n MAPG60 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX61 -nd ${U2UPGRADE} -n MAPG61 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX70 -nd ${U2UPGRADE} -n MAPG70 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX71 -nd ${U2UPGRADE} -n MAPG71 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX80 -nd ${U2UPGRADE} -n MAPG80 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX81 -nd ${U2UPGRADE} -n MAPG81 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX82 -nd ${U2UPGRADE} -n MAPG82 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX85 -nd ${U2UPGRADE} -n MAPG85 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX90 -nd ${U2UPGRADE} -n MAPG90 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX92 -nd ${U2UPGRADE} -n MAPG92 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MAPX93 -nd ${U2UPGRADE} -n MAPG93 -p ${U2PAT}
	# rename mon files
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX44 -nd ${U2UPGRADE} -n MONG44 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX50 -nd ${U2UPGRADE} -n MONG50 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX60 -nd ${U2UPGRADE} -n MONG60 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX61 -nd ${U2UPGRADE} -n MONG61 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX70 -nd ${U2UPGRADE} -n MONG70 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX71 -nd ${U2UPGRADE} -n MONG71 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX80 -nd ${U2UPGRADE} -n MONG80 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX81 -nd ${U2UPGRADE} -n MONG81 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX82 -nd ${U2UPGRADE} -n MONG82 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX85 -nd ${U2UPGRADE} -n MONG85 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX90 -nd ${U2UPGRADE} -n MONG90 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX92 -nd ${U2UPGRADE} -n MONG92 -p ${U2PAT}
	${DIFF} -a rename -od ${U2ORIGINAL} -o MONX93 -nd ${U2UPGRADE} -n MONG93 -p ${U2PAT}
	# create additional mon files
	${DIFF} -a create -nd ${U2UPGRADE} -n MONG20 -p ${U2PAT}
	${DIFF} -a copy -od ${U2ORIGINAL} -o MONG20 -nd ${U2UPGRADE} -n MONG10 -p ${U2PAT}
	${DIFF} -a copy -od ${U2ORIGINAL} -o MONG20 -nd ${U2UPGRADE} -n MONG15 -p ${U2PAT}
	${DIFF} -a copy -od ${U2ORIGINAL} -o MONG20 -nd ${U2UPGRADE} -n MONG30 -p ${U2PAT}
	${DIFF} -a copy -od ${U2ORIGINAL} -o MONG20 -nd ${U2UPGRADE} -n MONG40 -p ${U2PAT}
	${DIFF} -a copy -od ${U2ORIGINAL} -o MONG20 -nd ${U2UPGRADE} -n MONG45 -p ${U2PAT}

${U3PAT}: ${U3UPGRADE}/ULTIMA.COM ${U3UPGRADE}/BOOTUP.BIN ${U3UPGRADE}/EXODUS.BIN ${U3UPGRADE}/DUNGEON.DAT
	rm -f ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -o ULTIMA.COM -nd ${U3UPGRADE} -n ULTIMA.COM -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -o BOOTUP.BIN -nd ${U3UPGRADE} -n BOOTUP.BIN -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -o EXODUS.BIN -nd ${U3UPGRADE} -n EXODUS.BIN -p ${U3PAT}
	${DIFF} -od ${U3ORIGINAL} -o DUNGEON.DAT -nd ${U3UPGRADE} -n DUNGEON.DAT -p ${U3PAT}

${U5PAT}: ${U5UPGRADE}/ULTIMA.EXE ${U5UPGRADE}/INTRO.OVL ${U5UPGRADE}/MAINOUT.OVL ${U5UPGRADE}/TOWN.OVL \
        ${U5UPGRADE}/DUNGEON.OVL ${U5UPGRADE}/ENDGAME.OVL ${U5UPGRADE}/FONT.OVL ${U5UPGRADE}/DATA.OVL
	rm -f ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o ULTIMA.EXE -nd ${U5UPGRADE} -n ULTIMA.EXE -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o INTRO.OVL -nd ${U5UPGRADE} -n INTRO.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o MAINOUT.OVL -nd ${U5UPGRADE} -n MAINOUT.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o TOWN.OVL -nd ${U5UPGRADE} -n TOWN.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o DUNGEON.OVL -nd ${U5UPGRADE} -n DUNGEON.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o ENDGAME.OVL -nd ${U5UPGRADE} -n ENDGAME.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o FONT.OVL -nd ${U5UPGRADE} -n FONT.OVL -p ${U5PAT}
	${DIFF} -od ${U5ORIGINAL} -o DATA.OVL -nd ${U5UPGRADE} -n DATA.OVL -p ${U5PAT}

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
