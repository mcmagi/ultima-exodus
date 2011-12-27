/* u2reset_tools.c */


#include	<stdio.h>

#include	"gendefs.h"
#include	"File.h"
#include	"u2reset.h"
#include	"u2defs.h"


/* global vars */
extern BOOL debug;


/* returns tile underneath moongate */
unsigned char get_moongate_tile(File *player)
{
	unsigned char mg_tile;			/* moongate tile */


	/* read byte from mgsave offset in player file */
	seek_through_file(player, PLAYER_MGSAVE_IDX, SEEK_SET);
	read_from_file(player, &mg_tile, 1);

	return mg_tile;
}

/* removes transports from map */
void remove_transport(File *map, unsigned char mg_tile)
{
	unsigned char mapbyte;			/* map byte */
	unsigned char tile;				/* tile to write */
	int i;						/* loop counter */
	BOOL found;					/* transport found flag */


	if (debug)
		printf("Removing transport\n");
	
	/* search for transports on map */
	for (i = 0; i < MAP_SZ; i++)
	{
		/* read tile from map */
		seek_through_file(map, i, SEEK_SET);
		read_from_file(map, &mapbyte, 1);

		/* check for transport */
		switch (mapbyte)
		{
		  case MOONGATE_TILE:
			/* moongate -> replace with tile from player */
			tile = mg_tile;
			found = TRUE;
			break;

		  case HORSE_TILE:
		  case PLANE_TILE:
		  case ROCKET_TILE:
			/* horse, plane, rocket -> replace with grass tile */
			tile = GRASS_TILE;
			found = TRUE;
			break;

		  case FRIGATE_TILE:
			/* frigate -> replace with water tile */
			tile = WATER_TILE;
			found = TRUE;
			break;

		  default:
			found = FALSE;
		}

		/* did we find a transport? */
		if (found)
		{
			if (debug)
				printf(" Transport: 0x%02x - offset 0x%04x = row 0x%02x,"
					" col 0x%02x\n", mapbyte, i, i/64, i%64);

			/* write replacement tile to map */
			seek_through_file(map, i, SEEK_CUR);
			write_to_file(map, &tile, 1);
		}
	}
}

/* removes monsters from map */
void remove_monsters(File *map, File *mon)
{
	unsigned char tiles[NUM_MONS];	/* tiles underneath monsters */
	unsigned char monsters[NUM_MONS];	/* tiles of monsters */
	unsigned char cols[NUM_MONS];		/* monsters' columns */
	unsigned char rows[NUM_MONS];		/* monsters' rows */
	unsigned char mapbyte;			/* map byte */
	int position;					/* position of a monster */
	int i;						/* loop counter */


	if (debug)
		printf("Removing monsters\n");

	/* read monster location info */
	seek_through_file(mon, 0, SEEK_SET);
	read_from_file(mon, cols, NUM_MONS);
	read_from_file(mon, rows, NUM_MONS);

	/* skip over hit points */
	seek_through_file(mon, NUM_MONS * 3, SEEK_SET);

	/* read monster tiles */
	read_from_file(mon, monsters, NUM_MONS);
	read_from_file(mon, tiles, NUM_MONS);

	/* check each monster */
	for (i = 0; i < NUM_MONS; i++)
	{
		/* seek to monster position */
		position = rows[i] * NUM_COLS + cols[i];
		seek_through_file(map, position, SEEK_SET);

		/* get tile at monster position */
		read_from_file(map, &mapbyte, 1);

		if (monsters[i] != 0 && mapbyte != WATER_TILE
		  && mapbyte != GRASS_TILE && mapbyte != FOREST_TILE)
		{
			if (debug)
				printf(" Monster: 0x%02x - offset 0x%04x = row 0x%02x,"
					" col 0x%02x\n", mapbyte, position, rows[i], cols[i]);

			/* overwrite monster */
			seek_through_file(map, position, SEEK_SET);
			write_to_file(map, &tiles[i], 1);
		}
	}
}

/* writes List to a mapfile */
void write_item_list(File *map, List items)
{
	struct item *item_list;				/* ptr to item list */
	int i;							/* loop counter */


	/* create pointer to list */
	item_list = (struct item *) items.list;

	/* loop through each item in list */
	for (i = 0; i < items.num; i++)
	{
		if (debug)
			printf(" Writing: 0x%02x - list number 0x%04x = row 0x%02x, col"
				" 0x%02x\n", item_list[i].tile, i, item_list[i].row,
				item_list[i].col);

		add_tile(map, item_list[i]);
	}
}

/* sets a tile on the provided map file */
void add_tile(File *map, struct item tile)
{
	int position;					/* position of tile w/i file */


	/* calculate position */
	position = tile.row * NUM_COLS + tile.col;

	/* write tile to file */
	seek_through_file(map, position, SEEK_SET);
	write_to_file(map, &tile.tile, 1);
}
