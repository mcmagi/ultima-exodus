#ifndef _UPGRADE_H
#define _UPGRADE_H

#include "gendefs.h"

#define EXIT_NO_PATCH_FILES 1
#define EXIT_UNEXPECTED_VERSION 1
#define CURRENT_DIR	"."


typedef struct {
	const char *dir;
	File *applied;
	File *latest;
} PatchData;


/* Function prototypes */
PatchData *examine_patches(const char *path);
void free_patchdata(PatchData *data);
void do_upgrade(PatchData data);
void do_downgrade(PatchData data);
BOOL get_yesno();


#endif
