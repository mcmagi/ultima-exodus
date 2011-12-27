/* u3tools.c */


#include	"gendefs.h"
#include	"File.h"
#include	"FileUtil.h"
#include	"u3reset.h"
#include	"u3defs.h"


/* global vars */
extern BOOL debug;


/* returns number of party members */
int get_num_party_members(File *party)
{
	unsigned char num_party;				/* number of party members */


	/* seek to party member number offset */
	seek_through_file(party, NUM_PARTY_OFF, SEEK_SET);

	/* read number */
	read_from_file(party, &num_party, 1);

	if (debug)
		printf("Number of party members = %d\n", num_party);

	return (int) num_party;
}


/* removes horses, frigates, moongate, and whirlpool from map */
void remove_transport(File *sosaria)
{
	unsigned char mapbyte;				/* map byte */
	unsigned char tile;					/* tile to write */
	int i;							/* loop counter */
	BOOL found;						/* transport found flag */


	if (debug)
		printf("Removing transport\n");

	/* search for transports on map */
	for (i = 0; i < MAP_SZ; i++)
	{
		/* read tile from map */
		seek_through_file(sosaria, i, SEEK_SET);
 		read_from_file(sosaria, &mapbyte, 1);

		/* check for transport */
		switch (mapbyte)
		{
		  case MOONGATE_TILE:
		  case HORSE_TILE:
			/* horse -> replace with water tile */
		  	tile = GRASS_TILE;
			found = TRUE;
			break;

		  case WHIRLPOOL_TILE:
		  case FRIGATE_TILE:
			/* frigate, whirlpool -> replace with water tile */
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
				printf("Transport: 0x%02x - offset 0x%04x = row 0x%02x,"
					" col 0x%02x\n", mapbyte, i, i / 64, i % 64);

			/* write replacement tile to map */
			seek_through_file(sosaria, i, SEEK_CUR);
			write_to_file(sosaria, &tile, 1);
		}
	}
}


/* removes monsters from map */
void remove_monsters(File *sosaria)
{
	unsigned char blanks[MON_SZ];		/* blanks to overwrite monster info */
	unsigned char tiles[NUM_MONS];	/* tiles underneath monsters */
	unsigned char cols[NUM_MONS];		/* monsters' columns */
	unsigned char rows[NUM_MONS];		/* monsters' rows */
	unsigned char mapbyte;			/* map byte */
	int position;					/* position of a monster */
	int i;						/* loop counter */


	if (debug)
		printf("Removing monsters\n");


	/* read monster info */
	seek_through_file(sosaria, MON_OFF + NUM_MONS, SEEK_SET);
	read_from_file(sosaria, tiles, NUM_MONS);
	read_from_file(sosaria, cols, NUM_MONS);
	read_from_file(sosaria, rows, NUM_MONS);

	/* check each monster */
	for (i = 0; i < NUM_MONS; i++)
	{
		/* seek to monster position */
		position = rows[i] * NUM_COLS + cols[i];
		seek_through_file(sosaria, position, SEEK_SET);

		/* get tile at monster position */
		read_from_file(sosaria, &mapbyte, 1);

		/* check if monster is already gone */
		if (mapbyte != WATER_TILE && mapbyte != GRASS_TILE
		  && mapbyte != BRUSH_TILE && mapbyte != FOREST_TILE)
		{
			if (debug)
				printf("Monster: row 0x%02x, col 0x%02x\n", rows[i],
					cols[i]);

			/* overwrite monster */
			seek_through_file(sosaria, position, SEEK_SET);
			write_to_file(sosaria, &tiles[i], 1);
		}
	}

	/* clear monster info section */
	init_blanks(blanks, MON_SZ);
	seek_through_file(sosaria, MON_OFF, SEEK_SET);
	write_to_file(sosaria, blanks, MON_SZ);
}


/* resets moon data */
void reset_moons(File *sosaria)
{
	if (debug)
		printf("Resetting moon data\n");

	/* write new moon data */
	seek_through_file(sosaria, MOON_OFF, SEEK_SET);
	write_to_file(sosaria, moon_data, MOON_SZ);
}


/* resets whirlpool data */
void reset_whirlpool(File *sosaria)
{
	unsigned char tile = WHIRLPOOL_TILE;	/* tile to write */
	int position;						/* position of new whirlpool */


	if (debug)
		printf("Resetting whirlpool\n");

	/* write new whirlpool data */
	seek_through_file(sosaria, WHIRL_OFF, SEEK_SET);
	write_to_file(sosaria, whirl_data, WHIRL_SZ);

	/* set position of new whirlpool */
	position = WHIRL_ROW * NUM_COLS + WHIRL_COL;
	seek_through_file(sosaria, position, SEEK_SET);

	if (debug)
		printf("New Whirlpool location = row 0x%02x, col 0x%02x\n", WHIRL_ROW,
			WHIRL_COL);

	/* write whirlpool tile to map */
	write_to_file(sosaria, &tile, 1);
}
