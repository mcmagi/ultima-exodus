/* u2cfg.c */


#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>			/* strcpy */

#include	"u2cfg.h"				/* defs for u2cfg program */
#include	"gendefs.h"			/* general use defs */
#include	"file.h"				/* file handling */


int main(int argc, const char *argv[])
{
    struct u2cfg cfg;
	int option;						/* option */
	File *file;						/* File pointer */


	/* get file structure, then get data from it */
	file = stat_file(CFG);
	cfg = get_u2cfg(file);

	do
	{
		/* get user selection */
		option = menu(cfg);

		switch (option)
		{
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
	printf("%d - Autosave:       %s\n", AUTOSAVE_OPT, cfg.autosave ? ENABLED_STR : DISABLED_STR);
	printf("%d - Frame Limiter:  %s\n", FRAMELIMITER_OPT, cfg.framelimiter ? ENABLED_STR : DISABLED_STR);
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

void set_defaults(unsigned char data[])
{
	data[MUSIC_INDEX] = OFF;
	data[AUTOSAVE_INDEX] = OFF;
	data[FRAMELIMITER_INDEX] = ON;
	data[VIDEO_INDEX] = VIDEO_EGA;
	data[U2_ENHANCED_INDEX] = OFF;
	data[MOONGATE_INDEX] = MOONGATE_NONE;
}

struct u2cfg get_u2cfg(File *file)
{
	unsigned char data[CFG_SZ];			/* data string */
    struct u2cfg cfg;

    /* initialize data array to defaults */
    set_defaults(data);

    /* read config file */
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
	set_status(data, MOONGATE_INDEX, MOONGATE_NONE);

    /* overwrite file data */
    save_cfg_data(file, data);
}
