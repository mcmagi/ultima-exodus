/* fileutil.c */


#include	"FileUtil.h"


/* initializes a blank array */
void init_blanks(unsigned char blanks[], int size)
{
	int i;			/* loop counter */

	for (i = 0; i < size; i++)
		blanks[i] = '\0';
}


/* writes an array of blanks to the specified file */
void clear_file(File *zerofile)
{
	int size = zerofile->buf.st_size;	/* size of blank array */
	unsigned char blanks[size];		/* blank array */

	/* get blanks array */
	init_blanks(blanks, size);

	seek_through_file(zerofile, 0, SEEK_SET);
	write_to_file(zerofile, blanks, size);
}
