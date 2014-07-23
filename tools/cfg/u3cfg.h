#ifndef _U3CFG_H
#define _U3CFG_H


#include	"gendefs.h"
#include	"File.h"
#include	"cfg.h"


/* menu options */
#define	BAD_OPT                 0
#define	VIDEO_OPT               1
#define	MUSIC_OPT               2
#define	AUTOSAVE_OPT            3
#define	FRAMELIMITER_OPT        4
#define	MOON_PHASE_OPT          5
#define	GAMEPLAY_FIXES_OPT      6
#define	SAVE_QUIT_OPT           7
#define	QUIT_OPT                8

/* video menu options */
#define VIDEO_CGA_OPT           1
#define VIDEO_CGA_COMP_OPT      2
#define VIDEO_EGA_OPT           3
#define VIDEO_VGA_OPT           4
#define VIDEO_BACK_OPT          5

/* filename */
#define	CFG                     "U3.CFG"

struct u3cfg {
    int video;
    int music;
    BOOL autosave;
    BOOL framelimiter;
    BOOL moon_phases;
    BOOL gameplay_fixes;
};

/* function prototypes */
int menu(struct u3cfg cfg);
int video_menu(int video);
void set_defaults(unsigned char data[]);
struct u3cfg get_u3cfg(File *file, BOOL gen_defaults);
void save_u3cfg(File *file, struct u3cfg cfg);

#endif
