#ifndef _U5CFG_H
#define _U5CFG_H


#include	"gendefs.h"
#include	"file.h"
#include	"cfg.h"


/* menu options */
#define	BAD_OPT             0
#define	VIDEO_OPT           0
#define	MUSIC_OPT           1
#define	SAVE_QUIT_OPT       2
#define	QUIT_OPT            3

/* filename */
#define	CFG				"U5.CFG"

struct u5cfg {
    int video;
    int music;
};

/* function prototypes */
int menu(struct u5cfg cfg);
void set_defaults(unsigned char data[]);
struct u5cfg get_u5cfg(File *file);
void save_u5cfg(File *file, struct u5cfg cfg);

#endif
