/* u5datap.c */

#include <stdio.h>
#include <string.h>

#include "u5patch.h"
#include "gendefs.h"
#include "File.h"


int main(int argc, char *argv[])
{
	File *f;						/* file structure */


	printf("Applying the Ultima V Data Patch.\n");

	/* stat and open the file */
	f = stat_file(DATA_FILE);
	open_file(f, APPEND_MODE);

	/* patch midi driver data */
	patch(f, mid_offset, MID_SZ, "Midi Driver", "Ultima V", mid_olddata,
		mid_newdata);

	/* patch vga driver data */
	/*patch(f, vga_offset, VGA_SZ, "VGA Driver", "Ultima V", vga_olddata,
		vga_newdata);*/


	close_file(f);

	return SUCCESS;
};
