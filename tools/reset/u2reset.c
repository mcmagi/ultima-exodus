/* u2reset.c */


#include	<stdio.h>
#include	<string.h>          /* strcpy */

#include	"gendefs.h"
#include	"File.h"
#include	"FileUtil.h"
#include	"u2reset.h"


/* prototypes */
unsigned char reset_player_file();
void reset_map_file(const char *mapfn, const char *monfn, int start,
	int end, unsigned char mg_tile);
void populate_maps();


/* global vars */
BOOL debug;


int main(int argc, char *argv[])
{
	unsigned char mg_tile;		/* moongate tile */


	/* check for debug mode */
	if (argc == 2 && strcmp(argv[1], "-d") == MATCH)
		debug = TRUE;

	if (debug)
		printf("Resetting player file\n");

	/* clear player file, saving moongate tile */
	mg_tile = reset_player_file();

	if (debug)
		printf("Resetting map/mon files\n");

	/* clear all map files */
	reset_map_file(EMON, EMAP, E_START, E_END, mg_tile);
	reset_map_file(GMON, GMAP, G_START, G_END, mg_tile);

	if (debug)
		printf("Repopulating maps\n");

	/* repopulate maps with predefined tiles */
	populate_maps();

	printf("Game map reset.  Start Ultima II and create a new character.\n");

	return SUCCESS;
}

/* clears player file while saving moongate tile */
unsigned char reset_player_file()
{
	File *player;				/* party file */
	unsigned char mg_tile;		/* moongate tile */


	if (debug)
		printf("Opening file %s\n", PLAYER);

	/* open player party file */
	player = stat_file(PLAYER);
	open_file(player, READWRITE_MODE);

	if (debug)
		printf("Saving moongate tile from player file\n");

	/* get moongate tile */
	mg_tile = get_moongate_tile(player);

	if (debug)
		printf("Clearing contents of player file\n");

	/* clear the party file */
	clear_file(player);

	/* we have no need for player any longer */
	close_file(player);

	return mg_tile;
}

/* loops through map/mon files, clearing as we go */
void reset_map_file(const char *mapfn, const char *monfn, int start,
	int end, unsigned char mg_tile)
{
	File *map;				/* earth/galactic map file */
	File *mon;				/* monster file */
	int i;					/* loop counter */
	char mapfile[FILENAME_SZ+1];	/* map file name */
	char monfile[FILENAME_SZ+1];	/* mon file name */


	/* copy filenames for loop */
	strcpy(monfile, mapfn);
	strcpy(mapfile, monfn);

	/* loop through each mapfile */
	for (i = start; i <= end; i++)
	{
		/* set map number */
		mapfile[MAP_IDX] = monfile[MAP_IDX] = i + 0x30;

		if (debug)
			printf("Opening files %s, %s\n", mapfile, monfile);

		/* open map and monster files */
		mon = stat_file(monfile);
		open_file(mon, READWRITE_MODE);
		map = stat_file(mapfile);
		open_file(map, READWRITE_MODE);

		/* remove transports from map */
		remove_transport(map, mg_tile);

		/* remove monsters from map */
		remove_monsters(map, mon);

		/* clear monsters */
		clear_file(mon);

		/* close map and monster files */
		close_file(map);
		close_file(mon);
	}
}

/* writes preset monsters & transports to some maps */
void populate_maps()
{
	/* build minax's army in legends */
	write_legends_monsters();
	
	/* and give those monsters some personality */
	write_minax_monster_data();

	/* add some vehicles to pluto */
	write_pluto_transports();
}
