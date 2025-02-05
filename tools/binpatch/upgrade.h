#ifndef _UPGRADE_H
#define _UPGRADE_H

#include "gendefs.h"

#define EXIT_NO_PATCH_FILES 1
#define EXIT_UNEXPECTED_VERSION 1
#define HELPMSG			1
#define CURRENT_DIR	"."

#define INI_KEY_NONE		"none"
#define INI_KEY_RELEASES	"releases"
#define INI_KEY_BASE		"base"
#define INI_KEY_README		"readme"
#define INI_KEY_CONFIG		"config"

#define README_PAGE_BREAK	"---"


typedef struct {
	BOOL yes;
	BOOL debug;
	char *upgrade_type;
} UpgradeArgs;

typedef struct {
	const char *dir;
	BOOL has_upgrade;		/* true if applied patch is an upgrade */
	File *applied;			/* currently applied patch level */
	File *latest;			/* latest upgrade level */
	int num_below;			/* number of patches below base */
	File **below;			/* release patches below base */
	int num_above;			/* number of patches above base */
	File **above;			/* release patches above base */
} PatchData;


/* Function prototypes */
void examine_upgrade_patches(PatchData *r, const char *upgrade_type);
void examine_release_patches(PatchData *r, const IniCfg *iniCfg);
BOOL can_patch_be_applied(PatchData *r);
PatchData *create_patchdata(const char *path);
void free_patchdata(PatchData *data);
void do_upgrade(IniCfg *iniCfg, PatchData *data);
void do_downgrade(IniCfg *iniCfg, PatchData *data);
void upgrade_patch(IniCfg *iniCfg, File *patch, const char *dir);
void downgrade_patch(IniCfg *iniCfg, File *patch, const char *dir);
BOOL get_yesno();
IniCfg * load_upgrade_ini(const char *upgrade_type);
char * get_patch_version(const IniCfg *iniCfg, const File *patch);
void print_readme(char *filename);
void press_enter();
void invoke_config(IniCfg *iniCfg);
UpgradeArgs parse_args(int argc, const char **argv);
void print_help_message(const char *name);

#ifndef TARGET_ID
#define TARGET_ID 0
#endif

#if TARGET_ID == 0
#define TARGET "local"
#elif TARGET_ID == 1
#define TARGET "dos"
#elif TARGET_ID == 2
#define TARGET "win"
#elif TARGET_ID == 3
#define TARGET "linux"
#else
#define TARGET "unknown"
#endif


#endif
