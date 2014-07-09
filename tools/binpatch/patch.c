/* patch.c */


#include	<string.h>          /* strcpy, strncpy, strncmp, strlen */
#include    <stdlib.h>          /* printf, fprintf */

#include	"File.h"
#include	"gendefs.h"
#include	"patch.h"


struct patch_header build_patch_header(long size)
{
	struct patch_header pz;				/* patch header */


	strncpy(pz.hdr, PATCH_HEADER_ID, HDR_SZ);
	pz.ver = PATCH_VER;
	pz.size = size;

	return pz;
}

struct file_header build_file_header(const char filename[], const char newname[], long size)
{
	struct file_header fz;				/* file header */


	strncpy(fz.hdr, FILE_HEADER_ID, HDR_SZ);
	fz.ver = FILE_VER;
	set_filename(fz.name, filename);

	if (newname != NULL && strlen(newname) > 0)
	{
		set_filename(fz.newname, newname);
		fz.newname_flag = TRUE;
	}
	else
	{
		set_filename(fz.newname, EMPTY_STR);
		fz.newname_flag = FALSE;
	}

	fz.size = size;

	return fz;
}


struct data_header build_data_header(long offset, long size, short type)
{
	struct data_header dz;				/* data header */


	strncpy(dz.hdr, DATA_HEADER_ID, HDR_SZ);
	dz.ver = DATA_VER;
	dz.offset = offset;
	dz.size = size;
	dz.type = type;

	return dz;
}

/* sets charptr out with the filename in, checking size */
void set_filename(char *out, const char *in)
{
	int i;

	/* first, blank out string */
	for (i = 0; i < FT_NAME_SZ; i++)
		out[i] = 0;

	/* truncate if > max length */
	if (strlen(in) > FT_NAME_SZ)
		strncpy(out, in, FT_NAME_SZ);
	else
		strcpy(out, in);
}

void verify_patch_header(File *patch)
{
	struct patch_header pz;					/* patch header */


	/* read header from file */
	seek_through_file(patch, 0, SEEK_SET);
	read_from_file(patch, &pz, sizeof(struct patch_header));

	if (strncmp(pz.hdr, PATCH_HEADER_ID, HDR_SZ) != MATCH)
	{
		/* header id did not match */
		fprintf(stderr, "Not a patch file! Verify failed!\n");
		exit(FAILURE);
	}
	else if (pz.ver != PATCH_VER)
	{
		/* wrong version */
		fprintf(stderr, "Patch file incorrect version! (expected=%c, actual=%c) Verify failed!\n", PATCH_VER, pz.ver);
		exit(FAILURE);
	}
	else if (pz.size != patch->buf.st_size)
	{
		/* wrong size */
		fprintf(stderr, "File size does not match size in header! (expected=%d, actual=%d) Verify failed!\n", pz.size, patch->buf.st_size);
		exit(FAILURE);
	}
	else
		/* nothing wrong */
		printf("Patch verified!\n");
}
