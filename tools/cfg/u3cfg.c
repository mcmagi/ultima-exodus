/* u3cfg.c */


#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>			/* strcpy */

#include	"u3cfg.h"				/* defs for u3cfg program */
#include	"gendefs.h"			    /* general use defs */
#include	"File.h"				/* file handling */


int main(int argc, const char *argv[])
{
    struct u3cfg cfg;
	int option;                     /* option */
	int video_option;               /* option */
	int moongate_option;            /* option */
	File *file;						/* File pointer */


	/* get file structure, then get data from it */
	file = stat_file(CFG);
	cfg = get_u3cfg(file);

	do
	{
		/* get user selection */
		option = menu(cfg);

		switch (option)
		{
		    case VIDEO_OPT:
                do
                {
                    video_option = video_menu(cfg.video);
                }
                while (video_option < VIDEO_CGA_OPT || video_option > VIDEO_BACK_OPT);

                if (video_option != VIDEO_BACK_OPT)
                {
                    cfg.video = video_option - 1;

                    if (cfg.video == VIDEO_VGA)
                        cfg.moongate = MOONGATE_CYCLE;
                    else
                        cfg.moongate = MOONGATE_SCROLL;
                }
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

            /* I've decided to handle this a different way, and not in this release. */
		    /* case MOONGATE_OPT:
                do
                {
			        moongate_option = moongate_menu(cfg.moongate);
                }
                while (moongate_option < MOONGATE_NONE_OPT || moongate_option > MOONGATE_BACK_OPT);

                if (moongate_option != MOONGATE_BACK_OPT)
                    cfg.moongate = moongate_option - 1;
			    break; */

		    case MOON_PHASE_OPT:
			    cfg.moon_phases = ! cfg.moon_phases;
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
	char input[BUFSIZ];						/* unedited input */

	int option = 0;						/* edited option */
	int i;								/* loop counter */


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

	printf("%d - Autosave:       %s\n", AUTOSAVE_OPT, cfg.autosave ? ENABLED_STR : DISABLED_STR);
	printf("%d - Frame Limiter:  %s\n", FRAMELIMITER_OPT, cfg.framelimiter ? ENABLED_STR : DISABLED_STR);
	printf("%d - Moon Phases:    %s\n", MOON_PHASE_OPT, cfg.moon_phases ? ENABLED_STR : DISABLED_STR);

    /* if (cfg.video == VIDEO_VGA)
    {
	    printf("%d - Moongate:       %s\n", MOONGATE_OPT,
             cfg.moongate == MOONGATE_CYCLE ? MOONGATE_CYCLE_STR :
             cfg.moongate == MOONGATE_SCROLL ? MOONGATE_SCROLL_STR :
             cfg.moongate == MOONGATE_NONE ? MOONGATE_NONE_STR :
                 EMPTY_STR);
    }
    else
	    printf("    Moongate:       %s\n", MOONGATE_SCROLL_STR); */

	printf("%d - Save & Quit\n", SAVE_QUIT_OPT);
	printf("%d - Quit without Saving\n", QUIT_OPT);
	printf("\noption: ");

	/* get input */
	for (i = 0; (input[i] = getchar()) != '\n'; i++);


	/* option is only returned if there is one character and it is an integer */
	if (i = 1 && input[0] >= 0x30 && input[0] <= 0x39)
		option = atoi(input);

	return option;
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
	printf("%d - Return to Main Menu\n", VIDEO_BACK_OPT);
	printf("\noption: ");

	/* get input */
	for (i = 0; (input[i] = getchar()) != '\n'; i++);

	/* option is only returned if there is one character and it is an integer */
	if (i = 1 && input[0] >= 0x30 && input[0] <= 0x39)
		option = atoi(input);

	return option;
}

int moongate_menu(int moongate)
{
	char input[BUFSIZ];						/* unedited input */
	int option = 0;						/* edited option */
    int i;


	printf("\nU3 Upgrade Configuration - Moongate Animation\n\n");
	printf("%d - No Animation %s\n", MOONGATE_NONE_OPT,
         moongate == MOONGATE_NONE ? SELECTED_STR : EMPTY_STR);
	printf("%d - Vertical Scroll %s\n", MOONGATE_SCROLL_OPT,
         moongate == MOONGATE_SCROLL ? SELECTED_STR : EMPTY_STR);
	printf("%d - Color Cycle (Recommended) %s\n", MOONGATE_CYCLE_OPT,
         moongate == MOONGATE_CYCLE ? SELECTED_STR : EMPTY_STR);
	printf("%d - Return to Main Menu\n", MOONGATE_BACK_OPT);
	printf("\noption: ");

	/* get input */
	for (i = 0; (input[i] = getchar()) != '\n'; i++);

	/* option is only returned if there is one character and it is an integer */
	if (i = 1 && input[0] >= 0x30 && input[0] <= 0x39)
		option = atoi(input);

	return option;
}

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = ON;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_VGA;
	data[U3_MOONS_INDEX] = ON;
	/* data[MOONGATE_INDEX] = MOONGATE_CYCLE; */
	data[MOONGATE_INDEX] = OFF;
}

struct u3cfg get_u3cfg(File *file)
{
	unsigned char data[CFG_SZ];			/* data string */
    struct u3cfg cfg;

    /* initialize data array to defaults */
    set_defaults(data);

    /* read config file */
    get_cfg_data(file, data);

    /* populate struct */
	cfg.video = get_status(data, VIDEO_INDEX);
	cfg.music = get_status(data, MUSIC_INDEX);
	cfg.autosave = get_status_bool(data, AUTOSAVE_INDEX);
	cfg.framelimiter = get_status_bool(data, FRAMELIMITER_INDEX);
	cfg.moon_phases = get_status_bool(data, U3_MOONS_INDEX);
	/* cfg.moongate = get_status(data, MOONGATE_INDEX); */
	cfg.moongate = OFF;

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
	set_status(data, MOONGATE_INDEX, cfg.moongate);

    /* overwrite file data */
    save_cfg_data(file, data);
}
