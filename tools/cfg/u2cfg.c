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
#include	"stringutil.h"			/* strclone */


int main(int argc, const char *argv[])
{
	struct u2cfg cfg;
	BOOL gen_defaults = FALSE;		/* flag to generate defaults only */
	int option;						/* option */
	int sub_option;					/* sub menu option */
	File *file;						/* File pointer */
	File *iniFile;
	IniCfg *iniCfg;					/* Ini option data */

	if (argc >= 2 && strcmp(argv[1], OPT_GEN_DEFAULTS) == MATCH)
		gen_defaults = TRUE;

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

	do
	{
		if (! gen_defaults)
			/* get user selection */
			option = menu(iniCfg, cfg);
		else
			option = SAVE_QUIT_OPT;

		switch (option)
		{
			case VIDEO_OPT:
				do
				{
					sub_option = video_menu(cfg.video);
				}
				while (sub_option != VIDEO_CGA_OPT && sub_option != VIDEO_EGA_OPT && sub_option != MAIN_MENU_OPT);

				if (sub_option != MAIN_MENU_OPT)
				{
					cfg.video = sub_option - 1;
					cfg.tileset = 0;
				}
				break;

			case TILESET_OPT:
				cfg.tileset = tileset_menu(iniCfg, cfg.video, cfg.tileset, 9);
				break;

			case AUTOSAVE_OPT:
				cfg.autosave = ! cfg.autosave;
				break;

			case FRAMELIMITER_OPT:
				cfg.framelimiter = ! cfg.framelimiter;
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

	return SUCCESS;
}


int menu(IniCfg *iniCfg, struct u2cfg cfg)
{
	/* print the menu */
	printf("\nU2 Upgrade Configuration\n\n");

	printf("%d - Video:          %s\n", VIDEO_OPT,
		 cfg.video == VIDEO_CGA ? VIDEO_CGA_STR :
		 cfg.video == VIDEO_CGA_COMP ? VIDEO_CGA_COMP_STR :
		 cfg.video == VIDEO_EGA ? VIDEO_EGA_STR :
		 cfg.video == VIDEO_VGA ? VIDEO_VGA_STR :
			 EMPTY_STR);

	printf("%d - Tileset:        %s\n", TILESET_OPT, get_tileset_name(iniCfg, get_tileset_filename(cfg.video, cfg.tileset)));
	printf("%d - Autosave:       %s\n", AUTOSAVE_OPT, cfg.autosave ? ENABLED_STR : DISABLED_STR);
	printf("%d - Frame Limiter:  %s\n", FRAMELIMITER_OPT, cfg.framelimiter ? ENABLED_STR : DISABLED_STR);
	printf("%c - Save & Quit\n", SAVE_QUIT_OPT);
	printf("%c - Quit without Saving\n", QUIT_OPT);
	printf("\noption: ");

	return get_option();
}

int video_menu(int video)
{
	printf("\nU2 Upgrade Configuration - Video Mode\n\n");
	printf("%d - CGA (4-color) %s\n", VIDEO_CGA_OPT,
		 video == VIDEO_CGA ? SELECTED_STR : EMPTY_STR);
	printf("%d - EGA (16-color) %s\n", VIDEO_EGA_OPT,
		 video == VIDEO_EGA ? SELECTED_STR : EMPTY_STR);
	printf("%c - Return to Main Menu\n", MAIN_MENU_OPT);
	printf("\noption: ");

	return get_option();
}

int tileset_menu(IniCfg *iniCfg, int video, char tilesetId, int tilesetIdIdx)
{
	List *list;						/* tileset list */
	int i;							/* loop counter */
	int option;						/* inputted option */
	BOOL option_valid = FALSE;		/* option validation result */
	char *filename;

	/* get list of */
	list = filter_dirlist(get_tileset_prefix(video));

	if (list->size > 0)
	{
		do
		{
			printf("\nU2 Upgrade Configuration - Tileset\n\n");

			/* print all entries */
			for (i = 0; i < list->size && i < 9; i++)
			{
				filename = (char *) list->entries[i];

				printf("%d - %s %s\n", i+1, get_tileset_name(iniCfg, filename),
						get_tileset_id(filename, tilesetIdIdx) == tilesetId ? SELECTED_STR : EMPTY_STR);
			}
			printf("%c - Return to Main Menu\n", MAIN_MENU_OPT);
			printf("\noption: ");

			option = get_option();
			option_valid = (option > 0 && option <= list->size) || option == MAIN_MENU_OPT;
			if (! option_valid)
				printf("\nInvalid option!\n");
		}
		while (! option_valid);

		/* resolve selection to tileset id */
		if (option != MAIN_MENU_OPT)
			tilesetId = get_tileset_id(list->entries[option-1], tilesetIdIdx);
	}

	list_free(list);

	return tilesetId;
}

int get_tileset_id(char *filename, int tilesetIdIdx)
{
	int tilesetId = 0;
	if (strlen(filename) > tilesetIdIdx)
		tilesetId = filename[tilesetIdIdx];
	return tilesetId;
}

char * get_tileset_name(IniCfg *iniCfg, char *filename)
{
	char *name;

	if (iniCfg != NULL)
		name = ini_get_value(iniCfg, filename);

	return name != NULL ? name : filename;
}

char * get_tileset_filename(int video, int tilesetId)
{
	char filename[BUFSIZ];

	if (tilesetId > 0)
		sprintf(filename, "%s.%c", get_tileset_prefix(video), tilesetId);
	else
		strcpy(filename, get_tileset_prefix(video));

	return filename;
}

char * get_tileset_prefix(int video)
{
	return video == VIDEO_EGA ? "EGATILES" : "CGATILES";
}

List * filter_dirlist(const char *prefix)
{
	File *dir;				/* dir file */
	DirList *dirlist;		/* dir listing */
	List *list;				/* filtered filename list */
	char *filename;			/* filename */
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

	return list;
}

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = OFF;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_EGA;
	data[U2_ENHANCED_INDEX] = OFF;
	data[GAMEPLAY_FIXES_INDEX] = OFF;
	data[MOD_INDEX] = OFF;
	data[TILESET_INDEX] = OFF;
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
	cfg.tileset = get_status(data, TILESET_INDEX);
	cfg.autosave = get_status_bool(data, AUTOSAVE_INDEX);
	cfg.framelimiter = get_status_bool(data, FRAMELIMITER_INDEX);

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
	set_status(data, GAMEPLAY_FIXES_INDEX, OFF);
	set_status(data, MOD_INDEX, OFF);
	set_status(data, TILESET_INDEX, cfg.tileset);

	/* overwrite file data */
	save_cfg_data(file, data);
}
