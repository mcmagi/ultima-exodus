/* u2cfg.c */


#include	<stdio.h>				/* printf, BUFSIZ */
#include	<string.h>				/* strcmp */

#include	"u2cfg.h"				/* defs for u2cfg program */
#include	"gendefs.h"				/* general use defs */
#include	"option.h"				/* option functions */
#include	"file.h"				/* file handling */


int main(int argc, const char *argv[])
{
	struct u2cfg cfg;
	BOOL gen_defaults = FALSE;		/* flag to generate defaults only */
	int option;						/* option */
	int sub_option;					/* sub menu option */
	File *file;						/* File pointer */

	if (argc >= 2 && strcmp(argv[1], OPT_GEN_DEFAULTS) == MATCH)
		gen_defaults = TRUE;

	/* get file structure, then get data from it */
	file = stat_file(CFG);
	cfg = get_u2cfg(file, gen_defaults);

	do
	{
		if (! gen_defaults)
			/* get user selection */
			option = menu(cfg);
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
					cfg.video = sub_option - 1;
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


int menu(struct u2cfg cfg)
{
	char input[BUFSIZ];						/* unedited input */

	int option = 0;						/* edited option */
	int i;								/* loop counter */


	/* print the menu */
	printf("\nU2 Upgrade Configuration\n\n");

	printf("%d - Video:          %s\n", VIDEO_OPT,
		 cfg.video == VIDEO_CGA ? VIDEO_CGA_STR :
		 cfg.video == VIDEO_CGA_COMP ? VIDEO_CGA_COMP_STR :
		 cfg.video == VIDEO_EGA ? VIDEO_EGA_STR :
		 cfg.video == VIDEO_VGA ? VIDEO_VGA_STR :
			 EMPTY_STR);

	printf("%d - Autosave:       %s\n", AUTOSAVE_OPT, cfg.autosave ? ENABLED_STR : DISABLED_STR);
	printf("%d - Frame Limiter:  %s\n", FRAMELIMITER_OPT, cfg.framelimiter ? ENABLED_STR : DISABLED_STR);
	printf("%c - Save & Quit\n", SAVE_QUIT_OPT);
	printf("%c - Quit without Saving\n", QUIT_OPT);
	printf("\noption: ");

	return get_option();
}

int video_menu(int video)
{
	char input[BUFSIZ];						/* unedited input */
	int option = 0;						/* edited option */
	int i;


	printf("\nU2 Upgrade Configuration - Video Mode\n\n");
	printf("%d - CGA (4-color) %s\n", VIDEO_CGA_OPT,
		 video == VIDEO_CGA ? SELECTED_STR : EMPTY_STR);
	printf("%d - EGA (16-color) %s\n", VIDEO_EGA_OPT,
		 video == VIDEO_EGA ? SELECTED_STR : EMPTY_STR);
	printf("%c - Return to Main Menu\n", MAIN_MENU_OPT);
	printf("\noption: ");

	return get_option();
}

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = OFF;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_EGA;
	data[U2_ENHANCED_INDEX] = OFF;
	data[GAMEPLAY_FIXES_INDEX] = OFF;
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

	/* overwrite file data */
	save_cfg_data(file, data);
}
