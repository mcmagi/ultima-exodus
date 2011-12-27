#ifndef	_U2_RESET
#define	_U2_RESET


#include	"File.h"


/* data structures */
struct item
{
	unsigned char row;				/* row number of tile */
	unsigned char col;				/* column number of tile */
	unsigned char tile;				/* tile number (* 4) */
};


/* tools function prototypes */
unsigned char get_moongate_tile(File *player);
void remove_transport(File *map, unsigned char mg_tile);
void remove_monsters(File *map, File *mon);
void write_item_list(File *map, List items);
void add_tile(File *map, struct item tile);

/* predef function prototypes */
void write_legends_monsters();
void write_pluto_transports();
List build_legends_monsters();
List build_pluto_transports();
void write_items(const char *filename, List item_list);
void write_minax_monster_data();


/* standard dos 8.3 = 12 chars w/ dot */
#define	FILENAME_SZ		12


/* filenames */
#define	SOSARIA			"SOSARIA.ULT"
#define	PARTY			"PARTY.ULT"
#define	PLAYER			"PLAYER"
#define	EMAP				"MAPX00"
#define	EMON				"MONX00"
#define	GMAP				"MAPG00"
#define	GMON				"MONG00"


/* map file info */
#define	G_START			1
#define	G_END			9
#define	E_START			0
#define	E_END			4
#define	MAP_IDX			4


#endif
