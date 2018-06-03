#ifndef _U2CFG_H
#define _U2CFG_H


#include	"gendefs.h"
#include	"File.h"
#include	"List.h"
#include	"IniCfg.h"
#include	"cfg.h"


/* menu options */
#define	BAD_OPT			        0
#define	VIDEO_OPT               1
#define	THEME_OPT               2
#define	AUTOSAVE_OPT            3
#define	FRAMELIMITER_OPT        4
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
#define	INI				"U2UP.INI"

#define THEME_SZ				3

struct u2cfg {
    int video;
	char theme[THEME_SZ+1];
    int music;
    BOOL autosave;
    BOOL framelimiter;
    BOOL enhanced_ui;
    BOOL gameplay_fixes;
    int sfx;
    int mod;
};

typedef struct {
	char *value;
	char *name;
} Option;

/* function prototypes */
int menu(List *themeList, struct u2cfg cfg);
int video_menu(int video);
char * theme_menu(List *list, char *themeId);
char * get_theme_name(IniCfg *iniCfg, char *filename);
char * get_theme_prefix(int video);
List * filter_dirlist(const char *prefix);
List * get_theme_options(IniCfg *iniCfg, int video);
Option * get_selected_option(List *themeList, char *selected);
void set_defaults(unsigned char data[]);
struct u2cfg get_u2cfg(File *file, BOOL gen_defaults);
void save_u2cfg(File *file, struct u2cfg cfg);

#endif
