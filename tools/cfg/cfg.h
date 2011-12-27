#ifndef _CFG_H
#define _CFG_H


#include	"gendefs.h"
#include	"file.h"


/* function prototypes */
int menu(BOOL midi, BOOL autosave, BOOL framelimiter, BOOL vga);
BOOL get_status(const unsigned char data[], int index);
void set_defaults(unsigned char defaults[]);

void set_status(unsigned char data[], int index, BOOL status);
void get_cfg_data(File *file, unsigned char *data, const unsigned char *defaults);
void save_cfg_data(File *file, const unsigned char *data);

/* filename */
#define	CFG_SZ			4

/* data indexes */
#define	MIDI_INDEX		0
#define	AUTOSAVE_INDEX		1
#define	FRAMELIMITER_INDEX	2
#define	EGAVGA_INDEX		3

/* status strings */
#define	DISABLE_STR		"DISABLE"
#define	ENABLE_STR		"ENABLE"
#define	EGA_STR			"EGA"
#define	VGA_STR			"VGA"

/* status str sizes */
#define	STATUS_STR_SZ		7
#define	EGA_VGA_SZ		3

/* status on/off values */
#define	OFF				0x00
#define	ON				0x01


#endif
