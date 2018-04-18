#ifndef _U2CFG_H
#define _U2CFG_H


#include	"gendefs.h"
#include	"File.h"
#include	"cfg.h"


/* menu options */
#define	BAD_OPT			        0
#define	VIDEO_OPT               1
#define	AUTOSAVE_OPT            2
#define	FRAMELIMITER_OPT        3
#define	SAVE_QUIT_OPT           'S'
#define	QUIT_OPT                'Q'
#define MAIN_MENU_OPT           'M'

/* video menu options */
#define VIDEO_CGA_OPT           1
#define VIDEO_CGA_COMP_OPT      2
#define VIDEO_EGA_OPT           3
#define VIDEO_VGA_OPT           4

/* filename */
#define	CFG				"U2.CFG"

struct u2cfg {
    int video;
    BOOL autosave;
    BOOL framelimiter;
};

/* function prototypes */
int menu(struct u2cfg cfg);
int video_menu(int video);
void set_defaults(unsigned char data[]);
struct u2cfg get_u2cfg(File *file, BOOL gen_defaults);
void save_u2cfg(File *file, struct u2cfg cfg);

#endif
