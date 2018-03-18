/* u3cfg.c */


#include	<stdio.h>				/* printf, BUFSIZ */
#include	<string.h>				/* strcmp */

#include	"u3cfg.h"				/* defs for u3cfg program */
#include	"gendefs.h"				/* general use defs */
#include	"option.h"				/* option functions */
#include	"File.h"				/* file handling */


int main(int argc, const char *argv[])
{
	struct u3cfg cfg;
	BOOL gen_defaults = FALSE;		/* flag to generate defaults only */
	int option;						/* option */
	int sub_option;					/* sub menu option */
	File *file;						/* File pointer */

	if (argc >= 2 && strcmp(argv[1], OPT_GEN_DEFAULTS) == MATCH)
		gen_defaults = TRUE;

	/* get file structure, then get data from it */
	file = stat_file(CFG);
	cfg = get_u3cfg(file, gen_defaults);

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
				while ((sub_option < VIDEO_CGA_OPT || sub_option > VIDEO_VGA_OPT) && sub_option != MAIN_MENU_OPT);

				if (sub_option != MAIN_MENU_OPT)
					cfg.video = sub_option - 1;
				break;

			case MUSIC_OPT:
				if (cfg.music == MUSIC_MIDI)
					cfg.music = MUSIC_NONE;
				else
					cfg.music = MUSIC_MIDI;
				break;

			case AUTOSAVE_OPT:
				cfg.autosave = ! cfg.autosave;
				break;

			case FRAMELIMITER_OPT:
				cfg.framelimiter = ! cfg.framelimiter;
				break;

			case GAMEPLAY_FIXES_OPT:
				cfg.gameplay_fixes = ! cfg.gameplay_fixes;
				break;

			case MOON_PHASE_OPT:
				cfg.moon_phases = ! cfg.moon_phases;
				break;

			case MOD_OPT:
				if (cfg.mod == MOD_ULTIMA3)
					cfg.mod = MOD_SOSARIA;
				else
					cfg.mod = MOD_ULTIMA3;
				break;

			case SFX_OPT:
				if (cfg.sfx == SFX_ORIG)
					cfg.sfx = SFX_TIMED;
				else
					cfg.sfx = SFX_ORIG;
				break;

			case SAVE_QUIT_OPT:
				save_u3cfg(file, cfg);
				option = QUIT_OPT;
				break;
		}
	}
	while (option != QUIT_OPT);

	/* close the file */
	close_file(file);

	return SUCCESS;
}


int menu(struct u3cfg cfg)
{
	/* print the menu */
	printf("\nU3 Upgrade Configuration\n\n");

	printf("%d - Video:          %s\n", VIDEO_OPT,
		 cfg.video == VIDEO_CGA ? VIDEO_CGA_STR :
		 cfg.video == VIDEO_CGA_COMP ? VIDEO_CGA_COMP_STR :
		 cfg.video == VIDEO_EGA ? VIDEO_EGA_STR :
		 cfg.video == VIDEO_VGA ? VIDEO_VGA_STR :
			 EMPTY_STR);

	printf("%d - Music:          %s\n", MUSIC_OPT,
		 cfg.music == MUSIC_NONE ? MUSIC_NONE_STR :
		 cfg.music == MUSIC_MIDI ? MUSIC_MIDI_STR :
			 EMPTY_STR);

	printf("%d - Sound Effects:  %s\n", SFX_OPT,
		 cfg.sfx == SFX_ORIG ? SFX_ORIG_STR :
		 cfg.sfx == SFX_TIMED ? SFX_TIMED_STR :
			 EMPTY_STR);

	printf("%d - Autosave:       %s\n", AUTOSAVE_OPT, cfg.autosave ? ENABLED_STR : DISABLED_STR);
	printf("%d - Frame Limiter:  %s\n", FRAMELIMITER_OPT, cfg.framelimiter ? ENABLED_STR : DISABLED_STR);
	printf("%d - Moon Phases:    %s\n", MOON_PHASE_OPT, cfg.moon_phases ? ENABLED_STR : DISABLED_STR);
	printf("%d - Gameplay Fixes: %s\n", GAMEPLAY_FIXES_OPT, cfg.gameplay_fixes ? ENABLED_STR : DISABLED_STR);

	printf("%d - Game Mod:       %s\n", MOD_OPT,
			cfg.mod == MOD_ULTIMA3 ? MOD_ULTIMA3_STR :
			cfg.mod == MOD_SOSARIA ? MOD_SOSARIA_STR :
			EMPTY_STR);

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


	printf("\nU3 Upgrade Configuration - Video Mode\n\n");
	printf("%d - CGA (4-color) %s\n", VIDEO_CGA_OPT,
		 video == VIDEO_CGA ? SELECTED_STR : EMPTY_STR);
	printf("%d - CGA Composite (16-color) %s\n", VIDEO_CGA_COMP_OPT,
		 video == VIDEO_CGA_COMP ? SELECTED_STR : EMPTY_STR);
	printf("%d - EGA (16-color) %s\n", VIDEO_EGA_OPT,
		 video == VIDEO_EGA ? SELECTED_STR : EMPTY_STR);
	printf("%d - VGA (256-color) %s\n", VIDEO_VGA_OPT,
		 video == VIDEO_VGA ? SELECTED_STR : EMPTY_STR);
	printf("%c - Return to Main Menu\n", MAIN_MENU_OPT);
	printf("\noption: ");

	return get_option();
}

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = MUSIC_MIDI;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_VGA;
	data[U3_MOONS_INDEX] = ON;
	data[GAMEPLAY_FIXES_INDEX] = ON;
	data[SFX_INDEX] = SFX_TIMED;
	data[MOD_INDEX] = MOD_ULTIMA3;
}

struct u3cfg get_u3cfg(File *file, BOOL gen_defaults)
{
	unsigned char data[CFG_SZ];			/* data string */
	struct u3cfg cfg;

	/* initialize data array to defaults */
	set_defaults(data);

	/* read config file */
	if (! gen_defaults)
		get_cfg_data(file, data);

	/* populate struct */
	cfg.video = get_status(data, VIDEO_INDEX);
	cfg.music = get_status(data, MUSIC_INDEX);
	cfg.autosave = get_status_bool(data, AUTOSAVE_INDEX);
	cfg.framelimiter = get_status_bool(data, FRAMELIMITER_INDEX);
	cfg.moon_phases = get_status_bool(data, U3_MOONS_INDEX);
	cfg.gameplay_fixes = get_status_bool(data, GAMEPLAY_FIXES_INDEX);
	cfg.sfx = get_status(data, SFX_INDEX);
	cfg.mod = get_status(data, MOD_INDEX);

	return cfg;
}

void save_u3cfg(File *file, struct u3cfg cfg)
{
	unsigned char data[CFG_SZ];			/* data string */

	/* populate data array */
	set_status(data, VIDEO_INDEX, cfg.video);
	set_status(data, MUSIC_INDEX, cfg.music);
	set_status_bool(data, AUTOSAVE_INDEX, cfg.autosave);
	set_status_bool(data, FRAMELIMITER_INDEX, cfg.framelimiter);
	set_status_bool(data, U3_MOONS_INDEX, cfg.moon_phases);
	set_status(data, GAMEPLAY_FIXES_INDEX, cfg.gameplay_fixes);
	set_status(data, SFX_INDEX, cfg.sfx);
	set_status(data, MOD_INDEX, cfg.mod);

	/* overwrite file data */
	save_cfg_data(file, data);
}
