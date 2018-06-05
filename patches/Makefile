# directories
ROOT = ..
include ${ROOT}/Makefile.include

# upgrade patch filenames
U2PAT = ${PATCHES}/u2up-$(call stripdots,${U2VER}).pat
U3PAT = ${PATCHES}/u3up-$(call stripdots,${U3VER}).pat
U5PAT = ${PATCHES}/u5up-$(call stripdots,${U5VER}).pat

# incremental patch filenames
U2PAT_UC = ${PATCHES}/u2-uc.pat
U2PAT_MAP = ${PATCHES}/u2-map.pat
U2PAT_GOG = ${PATCHES}/u2-gog.pat
U2PAT_V11 = ${PATCHES}/u2up-11.pat
U2PAT_V12 = ${PATCHES}/u2up-12.pat

# patch save dir
U2_SAVE_DIR = PLAYER.U2

all: package

clean:
	rm -f ${U2PAT} ${U3PAT} ${U5PAT}

### patch build targets ###

patch: ${U2PAT} ${U3PAT} ${U5PAT}

patch_u2: ${U2PAT_UC} ${U2PAT_MAP} ${U2PAT_GOG} ${U2PAT_V11} ${U2PAT_V12} ${U2PAT}

patch_u3: ${U3PAT}

patch_u5: ${U5PAT}

${U2PAT_UC}:
	rm -f ${U2PAT_UC}
	# UC just has speed fix
	${DIFF} -od ${U2U16} -nd ${U2UC} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PAT_UC}

${U2PAT_MAP}:
	rm -f ${U2PAT_MAP}
	# patch binary with galactic map patch
	${DIFF} -od ${U2UC} -nd ${U2MAP} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PAT_MAP}
	# patch greenland dungeon
	${DIFF} -od ${U2UC} -nd ${U2MAP} -o MAPX10 -n MAPX10 -p ${U2PAT_MAP}
	${DIFF} -od ${U2UC} -nd ${U2MAP} -o MAPX15 -n MAPX15 -p ${U2PAT_MAP}
	# rename existing galactic map & monster files
	for i in 44 50 60 61 70 71 80 81 82 85 90 92 93; do \
		${DIFF} -a move -od ${U2UC} -nd ${U2MAP} -o MAPX$${i} -n MAPG$${i} -p ${U2PAT_MAP}; \
		${DIFF} -a move -od ${U2UC} -nd ${U2MAP} -o MONX$${i} -n MONG$${i} -p ${U2PAT_MAP}; \
	done
	# rename existing galactic talk files
	for i in 61 71 81 82 92 93; do \
		${DIFF} -a move -od ${U2UC} -nd ${U2MAP} -o TLKX$${i} -n TLKG$${i} -p ${U2PAT_MAP}; \
	done
	# add missing galactic map & monster files
	for i in 10 15 20 30 32 40 41 45; do \
		${DIFF} -a add -nd ${U2MAP} -n MAPG$${i} -p ${U2PAT_MAP}; \
		${DIFF} -a add -nd ${U2MAP} -n MONG$${i} -p ${U2PAT_MAP}; \
	done
	# add missing galactic talk files
	for i in 32 41; do \
		${DIFF} -a add -nd ${U2MAP} -n TLKG$${i} -p ${U2PAT_MAP}; \
	done

${U2PAT_GOG}:
	rm -f ${U2PAT_GOG}
	# GOG has galactic mon files truncated to 256
	for i in 10 15 30 40 45; do \
		${DIFF} -od ${U2MAP} -nd ${U2GOG} -o MONG$${i} -n MONG$${i} -p ${U2PAT_GOG}; \
	done
	# GOG has the upgrade's earth & galactic talk files with lowercase content
	for i in X03 X11 X21 X22 X23 X31 X32 X33 X41 G32 G41 G61 G71 G81 G82 G92 G93; do \
		${DIFF} -od ${U2MAP} -nd ${U2GOG} -o TLK$${i} -n TLK$${i} -p ${U2PAT_GOG}; \
	done

${U2PAT_V11}:
	rm -f ${U2PAT_V11}
	${DIFF} -a copy -od ${U2GOG} -nd ${U2UP_V11} -o ULTIMAII.EXE -n U2EGA.EXE -p ${U2PAT_V11}
	${DIFF} -od ${U2GOG} -nd ${U2UP_V11} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PAT_V11}

${U2PAT_V12}:
	rm -f ${U2PAT_V12}
	${DIFF} -od ${U2GOG} -nd ${U2UP_V12} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PAT_V12}

${U2PAT}:
	rm -f ${U2PAT}
	${DIFF} -od ${U2MAP} -nd ${U2UPGRADE} -o ULTIMAII.EXE -n ULTIMAII.EXE -p ${U2PAT}
	# patch lower-case content to earth & galactic talk files
	for i in X03 X11 X21 X22 X23 X31 X32 X33 X41 G32 G41 G61 G71 G81 G82 G92 G93; do \
		${DIFF} -od ${U2MAP} -nd ${U2UPGRADE} -o TLK$${i} -n TLK$${i} -p ${U2PAT}; \
	done
	# replace PLAYER and all overworld map/mon with master copies, backing up saves to PLAYER.U2
	${DIFF} -a replace -nd ${U2UPGRADE} -n PLAYER -o ${U2_SAVE_DIR}/PLAYER -p ${U2PAT}; \
	for i in X00 X10 X20 X30 X40 G10 G20 G30 G40 G50 G60 G70 G80 G90; do \
		${DIFF} -a replace -nd ${U2UPGRADE} -n MAP$${i} -o ${U2_SAVE_DIR}/MAP$${i} -p ${U2PAT}; \
		${DIFF} -a replace -nd ${U2UPGRADE} -n MON$${i} -o ${U2_SAVE_DIR}/MON$${i} -p ${U2PAT}; \
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
	cp -f ${U2PAT_UC} ${U2PKG}
	cp -f ${U2PAT_MAP} ${U2PKG}
	cp -f ${U2PAT_GOG} ${U2PKG}
	cp -f ${U2PAT_V11} ${U2PKG}
	cp -f ${U2PAT_V12} ${U2PKG}
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
