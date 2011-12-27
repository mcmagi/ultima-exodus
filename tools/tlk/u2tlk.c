/* u2tlk.c */


#include	<stdio.h>				/* fprintf */
#include	<stdlib.h>			/* exit */
#include	<malloc.h>			/* malloc, free */

#include	"gendefs.h"
#include	"File.h"
#include	"u2tlk.h"
#include	"tlklib.h"


int main(int argc, char *argv[])
{
	File *tlkfile;						/* u2 tlk file */
	struct u2tlk tlk;					/* u2 tlk data */


	/* check that one argument was supplied */
	if (argc != NUM_ARGS)
		print_help_message();

	/* 1st param should be tlk file */
	tlkfile = stat_file(argv[TLK_ARG]);
	open_file(tlkfile, READONLY_MODE);

	/* load talk data */
	tlk = load_tlk_data(tlkfile);

	/* print */
	print_all_tlk_msgs(tlk);

	/* free tlk data */
	free_tlk(&tlk);

	/* close tlk file */
	close_file(tlkfile);

	return SUCCESS;	
}

/* standard help message */
void print_help_message()
{
	fprintf(stderr, "U2 TLK Editor:  u2tlk <tlkfile>\n");
	exit(FAILURE);
}
