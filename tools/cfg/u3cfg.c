/* u3cfg.c */


#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>			/* strcpy */

#include	"u3cfg.h"				/* defs for u3cfg program */
#include	"gendefs.h"			/* general use defs */
#include	"file.h"				/* file handling */


int main(int argc, const char *argv[])
{
	BOOL midi;						/* midi flag */
	BOOL autosave;						/* autosave flag */
	BOOL framelimiter;					/* framelimiter flag */
	BOOL vga;							/* vga flag */
	int option;						/* option */
	
	unsigned char defaults[CFG_SZ];		/* 4-byte data string */
	unsigned char data[CFG_SZ];			/* 4-byte data string */
	
	File *file;						/* File pointer */


	/* set defaults values */
	set_defaults(defaults);

	/* get file structure, then get data from it */
	file = stat_file(CFG);
	get_cfg_data(file, data, defaults);

	/* get current info on all flags */
	midi = get_status(data, MIDI_INDEX);
	autosave = get_status(data, AUTOSAVE_INDEX);
	framelimiter = get_status(data, FRAMELIMITER_INDEX);
	vga = get_status(data, EGAVGA_INDEX);

	do
	{
		/* get user selection */
		option = menu(midi, autosave, framelimiter, vga);

		switch (option)
		{
		  case MIDI:
			midi = ! midi;
			set_status(data, MIDI_INDEX, midi);
			break;

		  case AUTOSAVE:
			autosave = ! autosave;
			set_status(data, AUTOSAVE_INDEX, autosave);
			break;

		  case FRAMELIMITER:
			framelimiter = ! framelimiter;
			set_status(data, FRAMELIMITER_INDEX, framelimiter);
			break;

		  /*case EGAVGA:
			vga = ! vga;
			set_status(data, EGAVGA_INDEX, vga);
			break;*/

		  case SAVE_QUIT:
			save_cfg_data(file, data);
			option = QUIT;
			break;
		}
	}
	while (option != QUIT);

	/* close the file */
	close_file(file);

	return SUCCESS;
}


int menu(BOOL midi, BOOL autosave, BOOL framelimiter, BOOL vga)
{
	char input[BUFSIZ];						/* unedited input */

	int option = 0;						/* edited option */
	int i;								/* loop counter */

	char midi_stat[STATUS_STR_SZ+1];			/* midi status string */
	char autosave_stat[STATUS_STR_SZ+1];		/* autosave status string */
	char framelimiter_stat[STATUS_STR_SZ+1];	/* framelimiter status string */
	char vga_stat[EGA_VGA_SZ+1];				/* vga status string */


	/* set status strings */
	if (midi)
		strcpy(midi_stat, DISABLE_STR);
	else
		strcpy(midi_stat, ENABLE_STR);

	if (autosave)
		strcpy(autosave_stat, DISABLE_STR);
	else
		strcpy(autosave_stat, ENABLE_STR);

	if (framelimiter)
		strcpy(framelimiter_stat, DISABLE_STR);
	else
		strcpy(framelimiter_stat, ENABLE_STR);

	if (vga)
		strcpy(vga_stat, EGA_STR);
	else
		strcpy(vga_stat, VGA_STR);

	/* print the menu */
	printf("\nU3 Upgrade Configuration\n\n");
	printf("%d - %s the MIDI music\n", MIDI, midi_stat);
	printf("%d - %s the Autosave\n", AUTOSAVE, autosave_stat);
	printf("%d - %s the Frame Limiter\n", FRAMELIMITER, framelimiter_stat);
	/* printf("%d - Set graphics mode to %s\n", EGAVGA, vga_stat); */
	printf("%d - Save & Quit\n", SAVE_QUIT);
	printf("%d - Quit without Saving\n", QUIT);
	printf("\noption: ");

	/* get input */
	for (i = 0; (input[i] = getchar()) != '\n'; i++);


	/* option is only returned if there is one characher and it is an integer */
	if (i = 1 && input[0] >= 0x30 && input[0] <= 0x39)
		option = atoi(input);

	return option;
}


void set_defaults(unsigned char defaults[])
{
	defaults[MIDI_INDEX] = ON;
	defaults[AUTOSAVE_INDEX] = OFF;
	defaults[FRAMELIMITER_INDEX] = ON;
	defaults[EGAVGA_INDEX] = OFF;
}
