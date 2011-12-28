#ifndef _CFG_H
#define _CFG_H


#include	"gendefs.h"
#include	"File.h"


/* function prototypes */
int get_status(const unsigned char data[], int index);
BOOL get_status_bool(const unsigned char data[], int index);
void set_status(unsigned char data[], int index, int status);
void set_status_bool(unsigned char data[], int index, BOOL status);
void get_cfg_data(File *file, unsigned char *data);
void save_cfg_data(File *file, const unsigned char *data);

/* file size */
#define	CFG_SZ                  6

/* data indexes */
#define	MUSIC_INDEX             0
#define	AUTOSAVE_INDEX          1
#define	FRAMELIMITER_INDEX      2
#define	VIDEO_INDEX             3
#define	U2_ENHANCED_INDEX       4
#define	U3_MOONS_INDEX          4
#define	U5_NONE_INDEX           4
#define	MOONGATE_INDEX          5

/* status strings */
#define	DISABLED_STR            "Disabled"
#define	ENABLED_STR             "Enabled"
#define	SELECTED_STR            "[SELECTED]"
#define	MUSIC_NONE_STR          "None"
#define	MUSIC_MIDI_STR          "MIDI Music"
#define	VIDEO_CGA_STR           "CGA (4-color)"
#define	VIDEO_CGA_COMP_STR      "CGA Composite (16-color)"
#define	VIDEO_EGA_STR           "EGA (16-color)"
#define	VIDEO_VGA_STR           "VGA (256-color)"
#define	MOONGATE_NONE_STR       "None"
#define	MOONGATE_SCROLL_STR     "Scroll"
#define	MOONGATE_CYCLE_STR      "Cycle"

/* music status values */
#define MUSIC_NONE              0
#define MUSIC_MIDI              1

/* video status values */
#define VIDEO_CGA               0
#define VIDEO_CGA_COMP          1
#define VIDEO_EGA               2
#define VIDEO_VGA               3

/* vga moongate status values */
#define MOONGATE_NONE           0
#define MOONGATE_SCROLL         1
#define MOONGATE_CYCLE          2

/* status str sizes */
#define	STATUS_STR_SZ           8
#define	VIDEO_STR_SZ            24
#define	MOONGATE_STR_SZ         6

/* status on/off values */
#define	OFF                     0x00
#define	ON                      0x01


#endif
