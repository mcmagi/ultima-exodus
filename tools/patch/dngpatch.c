/* u2patch.c */

#include <stdio.h>
#include <string.h>

#include "u2patch.h"
#include "gendefs.h"
#include "File.h"


int main(int argc, char *argv[])
{
	File *f;						/* file structure */


	printf("Applying the Ultima II Pangea Dungeon Patch.\n");


	/* patch Pangea Map */
	f = stat_file(PANGEA_MAP);
	open_file(f, APPEND_MODE);
	seek_through_file(f, pangea_offset, SEEK_SET);
	write_to_file(f, &pangea_newdata, PANGEA_SZ);
	close_file(f);

	printf("Patched %s - Pangea\n", PANGEA_MAP);


	/* patch Pangea Greenland Dungeon */
	f = stat_file(PANGEA_DNG);
	open_file(f, APPEND_MODE);
	seek_through_file(f, dungeon_offset, SEEK_SET);
	write_to_file(f, dungeon_newdata, DUNGEON_SZ);
	close_file(f);

	printf("Patched %s - Pangea Dungeon\n", PANGEA_DNG);

	return SUCCESS;
};

