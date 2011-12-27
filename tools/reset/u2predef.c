/* u2predef.c */


#include	<stdio.h>
#include	<malloc.h>

#include	"gendefs.h"
#include	"File.h"
#include	"u2reset.h"
#include	"u2predef.h"


/* global vars */
extern BOOL debug;


/* writes list of legends monsters to map file */
void write_legends_monsters()
{
	List legends_list;					/* List of monsters in Legends */


	if (debug)
		printf("Adding monsters to Legends map...\n");

	/* transfer items from List to mapfile */
	legends_list = build_legends_monsters();
	write_items(LEGENDS_MAP, legends_list);
	free(legends_list.list);
}

/* writes list of pluto transports to map file */
void write_pluto_transports()
{
	List pluto_list;					/* List of transports on Pluto */


	if (debug)
		printf("Adding transports to Pluto map...\n");

	/* transfer items from List to mapfile */
	pluto_list = build_pluto_transports();
	write_items(PLUTO_MAP, pluto_list);
	free(pluto_list.list);
}

/* builds a List of monsters on Legends */
List build_legends_monsters()
{
	List monlist;						/* List of monsters */
	struct item *mons;					/* ptr to monster list */
	int i;							/* loop counter */


	/* there are 31 monsters in Legends */
	monlist.num = NUM_MONS - 1;

	/* allocate memory */
	mons = malloc(sizeof(struct item) * monlist.num);

	/* build structure of monsters */
	for (i = 0; i < monlist.num; i++)
	{
		mons[i].col = minax_mondata[i + 0x01];
		mons[i].row = minax_mondata[i + 0x21];
		mons[i].tile = minax_mondata[i + 0x61];
	}

	/* generalize pointer & return List */
	monlist.list = (void *) mons;

	return monlist;
}

/* builds a List of transports on pluto */
List build_pluto_transports()
{
	List translist;					/* List of transports */
	struct item *trans;					/* ptr to transport list */


	/* there are four elements */
	translist.num = 4;

	/* allocate memory */
	trans = malloc(sizeof(struct item) * 4);

	/* copy defs */
	trans[0] = pluto_trans_1;
	trans[1] = pluto_trans_2;
	trans[2] = pluto_trans_3;
	trans[3] = pluto_trans_4;

	/* generalize pointer & return List */
	translist.list = (void *) trans;

	return translist;
}

/* transfers items in List to specified map filename */
void write_items(const char *mapname, List item_list)
{
	File *map;						/* map file pointer */

	/* open file, write the item list, and close it */
	map = stat_file(mapname);
	open_file(map, APPEND_MODE);
	write_item_list(map, item_list);
	close_file(map);
}

/* writes monster data to Legends mon file */
void write_minax_monster_data()
{
	File *mon;						/* Legends monster file */


	if (debug)
		printf("Updating Legends mon file...\n");

	/* write minax_mondata to mon file */
	mon = stat_file(LEGENDS_MON);
	open_file(mon, APPEND_MODE);
	seek_through_file(mon, 0, SEEK_SET);
	write_to_file(mon, minax_mondata, MINAX_DATA_SZ);
	close_file(mon);
}
