/* u2patch.c */

#include <stdio.h>
#include <string.h>

#include "u2patch.h"
#include "gendefs.h"
#include "File.h"


int main(int argc, char *argv[])
{
	unsigned char buffer[FILEIO_SZ];	/* buffer for binary code */
	File *f;						/* file structure */


	printf("Applying the Ultima II CGA Patch.\n");

	/* stat and open the file */
	f = stat_file(U2_EXE);
	open_file(f, APPEND_MODE);

	/* read old gmap data from file */
	seek_through_file(f, gmap_offset, SEEK_SET);
	read_from_file(f, buffer, GMAP_SZ);

	if (memcmp(buffer, gmap_olddata, GMAP_SZ) == MATCH)
	{
		/* read gmap data to file */
		seek_through_file(f, gmap_offset, SEEK_SET);
		write_to_file(f, gmap_newdata, GMAP_SZ);
		printf("Patched Galaxy Maps within %s\n", U2_EXE);
	}
	else if (memcmp(buffer, gmap_newdata, GMAP_SZ) == MATCH)
		printf("The Galaxy Map Patch has already been applied.\n");
	else
		printf("Unexpected data found while applying Galaxy Map Patch!\n"
			"Probably a different version of Ultima II found.  Please\n"
			"contact the Exodus Project so this problem can be fixed.\n");


	/* read old overflow data from file */
	seek_through_file(f, overflow_offset, SEEK_SET);
	read_from_file(f, buffer, OVERFLOW_SZ);

	if (memcmp(buffer, overflow_olddata, OVERFLOW_SZ) == MATCH)
	{
		/* read overflow data to file */
		seek_through_file(f, overflow_offset, SEEK_SET);
		write_to_file(f, overflow_newdata, OVERFLOW_SZ);
		printf("Applied Divide Overflow fix within %s\n", U2_EXE);
	}
	else if (memcmp(buffer, overflow_newdata, OVERFLOW_SZ) == MATCH)
		printf("The Divide Overflow Fix has already been applied.\n");
	else
		printf("Unexpected data found while applying Divide Overflow Fix!\n"
			"Probably a different version of Ultima II found.  Please\n"
			"contact the Exodus Project so this problem can be fixed.\n");


	/* read old piccas data from file */
	seek_through_file(f, piccas_offset, SEEK_SET);
	read_from_file(f, buffer, PICCAS_SZ);

	if (memcmp(buffer, piccas_olddata, PICCAS_SZ) == MATCH)
	{
		/* write piccas data to file */
		seek_through_file(f, piccas_offset, SEEK_SET);
		write_to_file(f, piccas_newdata, PICCAS_SZ);
		printf("Applied PICCAS patch in ultimaii.exe\n");
	}
	else if (memcmp(buffer, piccas_newdata, PICCAS_SZ) == MATCH)
		printf("The PICCAS Patch has already been applied.\n");
	else
		printf("Unexpected data found while applying PICCAS Patch!\n"
			"Probably a different version of Ultima II found.  Please\n"
			"contact the Exodus Project so this problem can be fixed.\n");


	/* read old fileio data from file */
	seek_through_file(f, fileio_offset, SEEK_SET);
	read_from_file(f, buffer, FILEIO_SZ);

	if (memcmp(buffer, fileio_olddata, FILEIO_SZ) == MATCH)
	{
		/* write fileio data to file */
		seek_through_file(f, fileio_offset, SEEK_SET);
		write_to_file(f, fileio_newdata, FILEIO_SZ);
		printf("Applied File IO patch in ultimaii.exe\n");
	}
	else if (memcmp(buffer, fileio_newdata, FILEIO_SZ) == MATCH)
		printf("The File IO Patch has already been applied.\n");
	else
		printf("Unexpected data found while applying the File IO Patch!\n"
			"Probably a different version of Ultima II found.  Please\n"
			"contact the Exodus Project so this problem can be fixed.\n");

	close_file(f);

	return SUCCESS;
};
