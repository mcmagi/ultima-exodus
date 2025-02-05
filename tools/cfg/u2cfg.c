/* u2cfg.c */


#include	<stdio.h>				/* printf, BUFSIZ */
#include	<stdlib.h>				/* NULL */
#include	<string.h>				/* strcmp */
#include	<strings.h>				/* strcasecmp */

#include	"u2cfg.h"				/* defs for u2cfg program */
#include	"gendefs.h"				/* general use defs */
#include	"option.h"				/* option functions */
#include	"File.h"				/* file handling */
#include	"DirList.h"				/* directory handling */
#include	"List.h"				/* List */
#include	"IniCfg.h"				/* IniCfg */
#include	"stringutil.h"
#include "filepath.h"			/* strclone */
#include "debug.h"


int main(int argc, const char *argv[])
{
	struct u2cfg cfg;
	BOOL gen_defaults = FALSE;		/* flag to generate defaults only */
	int option;						/* option */
	int sub_option;					/* sub menu option */
	File *file = NULL;				/* Config file pointer (owned) */
	File *iniFile = NULL;			/* Ini file pointer (owned) */
	IniCfg *iniCfg = NULL;			/* Ini option data (owned) */
	List *themeList = NULL;			/* theme list (owned) */

	if (argc >= 2 && strcmp(argv[1], OPT_GEN_DEFAULTS) == MATCH)
		gen_defaults = TRUE;

	if (argc >= 2 && strcmp(argv[1], OPT_VERBOSE) == MATCH)
		DEBUG = TRUE;

	/* get ini data */
	iniFile = stat_file("u2up.ini");
	if (! iniFile->newfile)
	{
		open_file(iniFile, READONLY_MODE);
		iniCfg = ini_load(iniFile);
	}
	close_file(iniFile);

	/* get file structure, then get data from it */
	file = stat_file(CFG);
	cfg = get_u2cfg(file, gen_defaults);

	themeList = get_theme_options(iniCfg, cfg.video);

	do
	{
		if (! gen_defaults)
			/* get user selection */
			option = menu(themeList, cfg);
		else
			option = SAVE_QUIT_OPT;

		switch (option)
		{
			case VIDEO_OPT:
				do
				{
					sub_option = video_menu(cfg.video);
				}
				while ((sub_option < VIDEO_CGA_OPT || sub_option > VIDEO_EGA_OPT) && sub_option != MAIN_MENU_OPT);

				if (sub_option != MAIN_MENU_OPT)
				{
					cfg.video = sub_option - 1;
					cfg.theme[0] = 0;
					free_options(themeList);
					themeList = get_theme_options(iniCfg, cfg.video);
				}
				break;

			case THEME_OPT:
				strcpy(cfg.theme, theme_menu(themeList, cfg.theme));
				break;

			case AUTOSAVE_OPT:
				cfg.autosave = ! cfg.autosave;
				break;

			case FRAMELIMITER_OPT:
				cfg.framelimiter = ! cfg.framelimiter;
				break;

			case GAMEPLAY_FIXES_OPT:
				/* temporary until we do the submenu thing with other fixes */
				cfg.gameplay_fixes = ! cfg.gameplay_fixes;
				break;

			case SAVE_QUIT_OPT:
				save_u2cfg(file, cfg);
				option = QUIT_OPT;
				break;
		}
	}
	while (option != QUIT_OPT);

	/* close the file */
	close_file(file);

	free_options(themeList);
	ini_free(iniCfg);

	return SUCCESS;
}


int menu(List *themeList, struct u2cfg cfg)
{
	Option *o = NULL;			/* selected theme option (reference) */

	/* print the menu */
	printf("\nU2 Upgrade Configuration\n\n");

	printf("%d - Video:          %s\n", VIDEO_OPT,
		 cfg.video == VIDEO_CGA ? VIDEO_CGA_STR :
		 cfg.video == VIDEO_CGA_COMP ? VIDEO_CGA_COMP_STR :
		 cfg.video == VIDEO_EGA ? VIDEO_EGA_STR :
		 cfg.video == VIDEO_VGA ? VIDEO_VGA_STR :
			 EMPTY_STR);

	o = get_selected_option(themeList, cfg.theme);
	if (themeList->size >= 2)
		printf("%d - Theme:          %s\n", THEME_OPT, o == NULL ? cfg.theme : o->name);
	else
		printf("    Theme:          %s\n", o == NULL ? cfg.theme : o->name);

	printf("%d - Autosave:       %s\n", AUTOSAVE_OPT, cfg.autosave ? ENABLED_STR : DISABLED_STR);
	printf("%d - Frame Limiter:  %s\n", FRAMELIMITER_OPT, cfg.framelimiter ? ENABLED_STR : DISABLED_STR);
	printf("%d - Stat Boost Fix: %s\n", GAMEPLAY_FIXES_OPT, cfg.gameplay_fixes ? ENABLED_STR : DISABLED_STR);
	printf("%c - Save & Quit\n", SAVE_QUIT_OPT);
	printf("%c - Quit without Saving\n", QUIT_OPT);
	printf("\noption: ");

	return get_option();
}

int video_menu(int video)
{
	printf("\nU2 Upgrade Configuration - Video Mode\n\n");
	printf("%d - %s %s\n", VIDEO_CGA_OPT, VIDEO_CGA_STR,
		 video == VIDEO_CGA ? SELECTED_STR : EMPTY_STR);
	printf("%d - %s %s\n", VIDEO_CGA_COMP_OPT, VIDEO_CGA_COMP_STR,
		 video == VIDEO_CGA_COMP ? SELECTED_STR : EMPTY_STR);
	printf("%d - %s %s\n", VIDEO_EGA_OPT, VIDEO_EGA_STR,
		 video == VIDEO_EGA ? SELECTED_STR : EMPTY_STR);
	printf("%c - Return to Main Menu\n", MAIN_MENU_OPT);
	printf("\noption: ");

	return get_option();
}

char * theme_menu(List *list, char *themeId)
{
	int i;							/* loop counter */
	int option;						/* inputted option */
	BOOL option_valid = FALSE;		/* option validation result */
	Option *o = NULL;				/* option entry (reference) */

	do
	{
		printf("\nU2 Upgrade Configuration - Theme\n\n");

		/* print all entries */
		for (i = 0; i < list->size && i < 10; i++)
		{
			o = (Option *) list->entries[i];

			printf("%d - %s %s\n", i, o->name,
					strcmp(o->value, themeId) == MATCH ? SELECTED_STR : EMPTY_STR);
		}
		printf("%c - Return to Main Menu\n", MAIN_MENU_OPT);
		printf("\noption: ");

		option = get_option();
		option_valid = (option >= 0 && option <= list->size && option < 10) || option == MAIN_MENU_OPT;
		if (! option_valid)
			printf("\nInvalid option!\n");
	}
	while (! option_valid);

	/* resolve selection to theme id */
	if (option != MAIN_MENU_OPT)
		themeId = ((Option *) list->entries[option])->value;

	return themeId;
}

char * get_theme_name(IniCfg *iniCfg, char *filename)
{
	char *name = NULL;			/* theme name (reference) */

	if (iniCfg != NULL)
		name = ini_get_value(iniCfg, filename);

	return name != NULL ? name : filename;
}

char * get_theme_prefix(int video)
{
	return video == VIDEO_VGA ? "VGATHEME" :
		video == VIDEO_EGA ? "EGATHEME" : "CGATHEME";
}

List * filter_dirlist(const char *prefix)
{
	File *dir;				/* dir file (owned & free) */
	DirList *dirlist;		/* dir listing (owned & free) */
	List *list;				/* filtered filename list (owned & returned) */
	char *filename;			/* filename (reference) */
	int i;					/* loop counter */
	int len;				/* prefix length */

	dir = stat_file(".");
	dirlist = list_dir(dir, NULL);
	list = list_create();
	len = strlen(prefix);

	/* add matching filename entries */
	for (i = 0; i < dirlist->size; i++)
	{
		filename = dirlist->entries[i]->filename;
		if (strncasecmp(filename, prefix, len) == MATCH)
			list_add(list, strclone(filename));
	}

	free_dirlist(dirlist);
	close_file(dir);

	return list;
}

List * get_theme_options(IniCfg *iniCfg, int video)
{
	List *fileList;							/* theme list (owned & free) */
	List *optionList;						/* option list (owned & returned) */
	Option *o = NULL;						/* option (owned & returned) */
	char *themePrefix;						/* theme filename prefix (reference) */
	char *themeFilename;					/* theme filename (reference) */
	FileParts *fileparts;					/* theme filename parts (owned & free) */
	int i;									/* loop counter */

	/* get list of matching filenames */
	themePrefix = get_theme_prefix(video);
	fileList = filter_dirlist(themePrefix);
	optionList = list_create();

	/* create default option entry */
	o = (Option *) malloc(sizeof(Option));
	o->value = strclone("");
	o->name = strclone(get_theme_name(iniCfg, themePrefix));
	list_add(optionList, o);

	for (i = 0; i < fileList->size; i++)
	{
		themeFilename = (char *) fileList->entries[i];
		fileparts = split_filename(themeFilename);

		if (fileparts->ext[0] != 0)
		{
			/* create option entry */
			o = (Option *) malloc(sizeof(Option));
			o->value = strclone(fileparts->ext);
			o->name = strclone(get_theme_name(iniCfg, themeFilename));
			list_add(optionList, o);
		}

		free_fileparts(fileparts);
	}

	list_free(fileList);

	return optionList;
}

Option * get_selected_option(List *themeList, char *selected)
{
	int i;			/* loop counter */
	Option *o;		/* option (owned & returned) */

	for (i = 0; i < themeList->size; i++)
	{
		o = (Option *) themeList->entries[i];

		if (strcmp(o->value, selected) == MATCH)
			return o;
	}

	return NULL;
}

void free_options(List *list)
{
	int i;			/* loop counter */
	Option *o;		/* option (owned & returned) */

	/* free data within in each option entry */
	for (i = 0; i < list->size; i++)
	{
		o = (Option *) list->entries[i];
		free(o->name);
		free(o->value);
	}

	list_free(list);
}

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = MUSIC_NONE;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_EGA;
	data[U2_ENHANCED_INDEX] = OFF;
	data[GAMEPLAY_FIXES_INDEX] = ON;
	data[SFX_INDEX] = SFX_ORIG;
	data[MOD_INDEX] = OFF;
	data[THEME_INDEX] = '\0';
}

struct u2cfg get_u2cfg(File *file, BOOL gen_defaults)
{
	unsigned char data[CFG_SZ];			/* data string */
	struct u2cfg cfg;

	/* initialize data array to defaults */
	set_defaults(data);

	/* read config file */
	if (! gen_defaults)
		get_cfg_data(file, data);

	/* populate struct */
	cfg.video = get_status(data, VIDEO_INDEX);
	get_status_str(data, THEME_INDEX, cfg.theme, THEME_SZ);
	cfg.theme[THEME_SZ] = '\0';
	cfg.autosave = get_status_bool(data, AUTOSAVE_INDEX);
	cfg.framelimiter = get_status_bool(data, FRAMELIMITER_INDEX);
	cfg.gameplay_fixes = get_status(data, GAMEPLAY_FIXES_INDEX);

	return cfg;
}

void save_u2cfg(File *file, struct u2cfg cfg)
{
	unsigned char data[CFG_SZ];			/* data string */

	/* populate data array */
	set_status(data, VIDEO_INDEX, cfg.video);
	set_status(data, MUSIC_INDEX, MUSIC_NONE);
	set_status_bool(data, AUTOSAVE_INDEX, cfg.autosave);
	set_status_bool(data, FRAMELIMITER_INDEX, cfg.framelimiter);
	set_status_bool(data, U2_ENHANCED_INDEX, FALSE);
	set_status(data, GAMEPLAY_FIXES_INDEX, cfg.gameplay_fixes);
	set_status(data, SFX_INDEX, SFX_ORIG);
	set_status(data, MOD_INDEX, OFF);
	set_status_str(data, THEME_INDEX, cfg.theme, THEME_SZ);

	/* overwrite file data */
	save_cfg_data(file, data);
}
