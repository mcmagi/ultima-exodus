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
#define	TILESET_OPT             2
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

struct u2cfg {
    int video;
	int tileset;
    int music;
    BOOL autosave;
    BOOL framelimiter;
    BOOL enhanced_ui;
    BOOL gameplay_fixes;
    int sfx;
    int mod;
};

/* function prototypes */
int menu(IniCfg *iniCfg, struct u2cfg cfg);
int video_menu(int video);
int tileset_menu(IniCfg *iniCfg, int video, char tilesetId, int tilesetIdIdx);
int get_tileset_id(char *filename, int tilesetIdIdx);
char * get_tileset_name(IniCfg *iniCfg, char *filename);
char * get_tileset_filename(int video, int tilesetId);
char * get_tileset_prefix(int video);
List * filter_dirlist(const char *prefix);
void set_defaults(unsigned char data[]);
struct u2cfg get_u2cfg(File *file, BOOL gen_defaults);
void save_u2cfg(File *file, struct u2cfg cfg);

#endif
