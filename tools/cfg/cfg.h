#ifndef _CFG_H
#define _CFG_H


#include	"gendefs.h"
#include	"File.h"


/* function prototypes */
int get_status(const unsigned char data[], int index);
BOOL get_status_bool(const unsigned char data[], int index);
void get_status_str(const unsigned char data[], int index, char *str, int len);
void set_status(unsigned char data[], int index, int status);
void set_status_bool(unsigned char data[], int index, BOOL status);
void set_status_str(unsigned char data[], int index, char *status, int len);
void get_cfg_data(File *file, unsigned char *data);
void save_cfg_data(File *file, const unsigned char *data);

/* command line options */
#define OPT_GEN_DEFAULTS		"--gen-defaults"
#define OPT_VERBOSE				"-v"

/* file size */
#define	CFG_SZ                  11

/* data indexes */
#define	MUSIC_INDEX             0
#define	AUTOSAVE_INDEX          1
#define	FRAMELIMITER_INDEX      2
#define	VIDEO_INDEX             3
#define	U2_ENHANCED_INDEX       4
#define	U3_MOONS_INDEX          4
#define	U5_NONE_INDEX           4
#define	GAMEPLAY_FIXES_INDEX    5
#define	SFX_INDEX               6
#define	MOD_INDEX               7
#define	THEME_INDEX             8

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
#define	SFX_ORIG_STR            "Unmodified"
#define	SFX_TIMED_STR           "Constant Speed (Timed)"
#define	MOD_ULTIMA2_STR         "Ultima II (Original)"
#define	MOD_ULTIMA3_STR         "Ultima III (Original)"
#define	MOD_SOSARIA_STR         "Sosaria Mod (Lands of Lord British)"

/* music status values */
#define MUSIC_NONE              0
#define MUSIC_MIDI              1

/* video status values */
#define VIDEO_CGA               0
#define VIDEO_CGA_COMP          1
#define VIDEO_EGA               2
#define VIDEO_VGA               3

/* sfx status values */
#define SFX_ORIG                0
#define SFX_TIMED               1

/* mod options */
#define MOD_ULTIMA3             0
#define MOD_SOSARIA             1

/* status str sizes */
#define	STATUS_STR_SZ           8
#define	VIDEO_STR_SZ            24
#define	MOD_STR_SZ              40
#define	MOONGATE_STR_SZ         6

/* status on/off values */
#define	OFF                     0x00
#define	ON                      0x01


#endif
