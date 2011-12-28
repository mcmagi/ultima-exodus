#ifndef _U2CFG_H
#define _U2CFG_H


#include	"gendefs.h"
#include	"File.h"
#include	"cfg.h"


/* menu options */
#define	BAD_OPT			    0
#define	VIDEO_OPT           0
#define	AUTOSAVE_OPT        1
#define	FRAMELIMITER_OPT    2
#define	SAVE_QUIT_OPT       3
#define	QUIT_OPT            4

/* filename */
#define	CFG				"U2.CFG"

struct u2cfg {
    int video;
    BOOL autosave;
    BOOL framelimiter;
};

/* function prototypes */
int menu(struct u2cfg cfg);
void set_defaults(unsigned char data[]);
struct u2cfg get_u2cfg(File *file);
void save_u2cfg(File *file, struct u2cfg cfg);

#endif
