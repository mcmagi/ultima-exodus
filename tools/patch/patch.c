/* patch.c */


#include	<stdio.h>
#include	<string.h>          /* memcmp */
#include	"gendefs.h"
#include	"File.h"


void patch(File *f, const long offset, const long size, const char *name, const
	char *game, const unsigned char *olddata, const unsigned char *newdata)
{
	unsigned char buffer[BUFSIZ];	/* buffer for binary code */


	/* read old data from file */
	seek_through_file(f, offset, SEEK_SET);
	read_from_file(f, buffer, size);

	if (memcmp(buffer, olddata, size) == MATCH)
	{
		/* write new data to file */
		seek_through_file(f, offset, SEEK_SET);
		write_to_file(f, newdata, size);
		printf("Patched %s within %s\n", name, f->filename);
	}
	else if (memcmp(buffer, newdata, size) == MATCH)
		printf("The %s has already been applied.\n", name);
	else
		printf("Unexpected data found while applying %s!\n"
			"Probably a different version of %s found.  Please\n"
			"contact the Exodus Project so this problem can be fixed.\n",
			name, game);

	return;
}
