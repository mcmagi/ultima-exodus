/* u5cfg.c */


#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>			/* strcpy */

#include	"u5cfg.h"				/* defs for u5cfg program */
#include	"gendefs.h"			/* general use defs */
#include	"file.h"				/* file handling */


int main(int argc, const char *argv[])
{
    struct u5cfg cfg;
	int option;						/* option */
	File *file;						/* File pointer */


	/* get file structure, then get data from it */
	file = stat_file(CFG);
	cfg = get_u5cfg(file);

	do
	{
		/* get user selection */
		option = menu(cfg);

		switch (option)
		{
		    case MUSIC_OPT:
                if (cfg.music == MUSIC_MIDI)
                    cfg.music = MUSIC_NONE;
                else
                    cfg.music = MUSIC_MIDI;
			    break;

		    case SAVE_QUIT_OPT:
			    save_u5cfg(file, cfg);
			    option = QUIT_OPT;
			    break;
		}
	}
	while (option != QUIT_OPT);

	/* close the file */
	close_file(file);

	return SUCCESS;
}


int menu(struct u5cfg cfg)
{
	char input[BUFSIZ];						/* unedited input */

	int option = 0;						/* edited option */
	int i;								/* loop counter */


	/* print the menu */
	printf("\nU5 Upgrade Configuration\n\n");
	printf("%d - Music:          %s\n", MUSIC_OPT,
         cfg.music == MUSIC_NONE ? MUSIC_NONE_STR :
         cfg.music == MUSIC_MIDI ? MUSIC_MIDI_STR :
             EMPTY_STR);
	printf("%d - Save & Quit\n", SAVE_QUIT_OPT);
	printf("%d - Quit without Saving\n", QUIT_OPT);
	printf("\noption: ");

	/* get input */
	for (i = 0; (input[i] = getchar()) != '\n'; i++);


	/* option is only returned if there is one characher and it is an integer */
	if (i = 1 && input[0] >= 0x30 && input[0] <= 0x39)
		option = atoi(input);

	return option;
}

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = ON;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_EGA;
	data[U5_NONE_INDEX] = OFF;
	data[MOONGATE_INDEX] = MOONGATE_CYCLE;
}

struct u5cfg get_u5cfg(File *file)
{
	unsigned char data[CFG_SZ];			/* data string */
    struct u5cfg cfg;

    /* initialize data array to defaults */
    set_defaults(data);

    /* read config file */
    get_cfg_data(file, data);

    /* populate struct */
	cfg.video = get_status(data, VIDEO_INDEX);
	cfg.music = get_status(data, MUSIC_INDEX);

    return cfg;
}

void save_u5cfg(File *file, struct u5cfg cfg)
{
	unsigned char data[CFG_SZ];			/* data string */

    /* populate data array */
	set_status(data, VIDEO_INDEX, cfg.video);
	set_status(data, MUSIC_INDEX, cfg.music);
	set_status_bool(data, AUTOSAVE_INDEX, FALSE);
	set_status_bool(data, FRAMELIMITER_INDEX, FALSE);
	set_status_bool(data, U5_NONE_INDEX, FALSE);
	set_status(data, MOONGATE_INDEX, OFF);

    /* overwrite file data */
    save_cfg_data(file, data);
}
