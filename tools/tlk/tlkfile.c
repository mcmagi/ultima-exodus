/* tlkfile.c */


#include	<stdio.h>
#include	<string.h>
#include    <stdlib.h>      /* malloc, free */

#include	"File.h"
#include	"tlklib.h"


/* loads u2tlk structure with tlk data from file */
struct u2tlk load_tlk_data(File *tlkfile)
{
	struct u2tlk tlk;					/* u2 tlk data */


	/* load tlk data into mem */
	tlk.size = tlkfile->buf.st_size;
	tlk.data = (unsigned char *) malloc(tlk.size);
	read_from_file(tlkfile, tlk.data, tlk.size);

	/* decode & index */
	decode_tlk_data(tlk);
	build_msg_index(&tlk);

	return tlk;
}

/* writes tlk data from u2tlk structure to file */
void save_tlk_data(File *tlkfile, struct u2tlk tlk)
{
	unsigned char *encoded_data;	    /* copy of tlk data */


	/* copy data for encoding */
	encoded_data = (unsigned char *) malloc(tlk.size);
	strncpy(encoded_data, tlk.data, tlk.size);

	/* point tlk structure to copy of data for encoding */
	tlk.data = encoded_data;

	/* encode data for write */
	encode_tlk_data(tlk);

	/* write out tlk data to file */
	seek_through_file(tlkfile, 0, SEEK_SET);
	write_to_file(tlkfile, tlk.data, tlk.size);

    free(encoded_data);
}

/* Frees resources used by the tlk data structure */
void free_tlk(struct u2tlk *tlk)
{
	/* free resources */
	free(tlk->data);
	free(tlk->msgs);

	/* nullify pointers */
	tlk->data = NULL;
	tlk->msgs = NULL;
}
