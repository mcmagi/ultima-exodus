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

${U2PAT}: ${U2UPGRADE}/ULTIMAII.EXE ${U2UPGRADE}/U2EGA.EXE ${U2UPGRADE}/MAPX10 ${U2UPGRADE}/MAPX15
	rm -f ${U2PAT}
	${DIFF} -s 3 -o ${U2ORIGINAL}/ULTIMAII.EXE -n ${U2UPGRADE}/U2EGA.EXE -p ${U2PAT} -u
	${DIFF} -s 3 -o ${U2ORIGINAL}/ULTIMAII.EXE -n ${U2UPGRADE}/ULTIMAII.EXE -p ${U2PAT}
	${DIFF} -s 3 -o ${U2ORIGINAL}/MAPX10 -n ${U2UPGRADE}/MAPX10 -p ${U2PAT}
	${DIFF} -s 3 -o ${U2ORIGINAL}/MAPX15 -n ${U2UPGRADE}/MAPX15 -p ${U2PAT}

${U3PAT}: ${U3UPGRADE}/ULTIMA.COM ${U3UPGRADE}/BOOTUP.BIN ${U3UPGRADE}/EXODUS.BIN ${U3UPGRADE}/DUNGEON.DAT
	rm -f ${U3PAT}
	${DIFF} -s 3 -o ${U3ORIGINAL}/ULTIMA.COM -n ${U3UPGRADE}/ULTIMA.COM -p ${U3PAT}
	${DIFF} -s 3 -o ${U3ORIGINAL}/BOOTUP.BIN -n ${U3UPGRADE}/BOOTUP.BIN -p ${U3PAT}
	${DIFF} -s 3 -o ${U3ORIGINAL}/EXODUS.BIN -n ${U3UPGRADE}/EXODUS.BIN -p ${U3PAT}
	${DIFF} -s 3 -o ${U3ORIGINAL}/DUNGEON.DAT -n ${U3UPGRADE}/DUNGEON.DAT -p ${U3PAT}

${U5PAT}: ${U5UPGRADE}/ULTIMA.EXE ${U5UPGRADE}/INTRO.OVL ${U5UPGRADE}/MAINOUT.OVL ${U5UPGRADE}/TOWN.OVL \
        ${U5UPGRADE}/DUNGEON.OVL ${U5UPGRADE}/ENDGAME.OVL ${U5UPGRADE}/FONT.OVL ${U5UPGRADE}/DATA.OVL
	rm -f ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/ULTIMA.EXE -n ${U5UPGRADE}/ULTIMA.EXE -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/INTRO.OVL -n ${U5UPGRADE}/INTRO.OVL -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/MAINOUT.OVL -n ${U5UPGRADE}/MAINOUT.OVL -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/TOWN.OVL -n ${U5UPGRADE}/TOWN.OVL -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/DUNGEON.OVL -n ${U5UPGRADE}/DUNGEON.OVL -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/ENDGAME.OVL -n ${U5UPGRADE}/ENDGAME.OVL -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/FONT.OVL -n ${U5UPGRADE}/FONT.OVL -p ${U5PAT}
	${DIFF} -s 3 -o ${U5ORIGINAL}/DATA.OVL -n ${U5UPGRADE}/DATA.OVL -p ${U5PAT}

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
