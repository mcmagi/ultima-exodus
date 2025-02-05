/* patch.c */


#include	<string.h>          /* strcpy, strncpy, strncmp, strlen */
#include    <stdlib.h>          /* printf, fprintf */

#include	"File.h"
#include	"List.h"
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

struct file_header build_file_header(const char filename[], const char newname[], int action, long size)
{
	struct file_header fz;				/* file header */


	strncpy(fz.hdr, FILE_HEADER_ID, HDR_SZ);
	fz.ver = FILE_VER;

	if (filename != NULL && strlen(filename) > 0)
		set_filename(fz.name, filename);
	else
		set_filename(fz.name, EMPTY_STR);

	if (newname != NULL && strlen(newname) > 0)
		set_filename(fz.newname, newname);
	else
		set_filename(fz.newname, EMPTY_STR);

    fz.action = (char) action;
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
}

List * build_patch_index(File *patch)
{
	char hdrtype[HDR_SZ];				/* holds header type */
	struct file_header fz;				/* header for patched file */
	struct data_header dz;				/* header for patch data */
	int datasize;						/* size of data to skip if error or deleted file */
	long pos = 0;						/* position in file */
	List *fzIndex;

	fzIndex = list_create();

	pos += sizeof(struct patch_header);

	/* read first header */
	read_from_file(patch, &hdrtype, HDR_SZ);

	while (! end_of_file(patch))
	{
		/* reset position */
		seek_through_file(patch, -HDR_SZ, SEEK_CUR);

		if (strncmp(hdrtype, FILE_HEADER_ID, HDR_SZ) == MATCH)
		{
			patch_index_add(fzIndex, pos);

			/* read next file header */
			read_from_file(patch, &fz, sizeof(struct file_header));
			pos += sizeof(struct file_header);
		}
		else if (strncmp(hdrtype, DATA_HEADER_ID, HDR_SZ) == MATCH)
		{
			/* read next data header */
			read_from_file(patch, &dz, sizeof(struct data_header));
			pos += sizeof(struct data_header);

			datasize = dz.size;
			if (dz.type == DT_REPLACE)
				datasize *= 2;

			seek_through_file(patch, datasize, SEEK_CUR);
			pos += datasize;
		}
		else
		{
			printf("Unrecognized header information reading patchfile %s\n", patch->filename);
			exit(FATAL_ERROR);
		}

		/* read next header */
		read_from_file(patch, &hdrtype, HDR_SZ);

	}

	/* return to first file header */
	if (fzIndex->size > 0)
		seek_through_file(patch, patch_index_get(fzIndex, 0), SEEK_SET);

	return fzIndex;
}

void patch_index_add(List *fzIndex, long value)
{
	long *x;			/* pointer to value */

	x = (long *) malloc(sizeof(long));
	*x = value;
	list_add(fzIndex, x);
}

long patch_index_get(List *fzIndex, int idx)
{
	long *value = (long *) fzIndex->entries[idx];
	return *value;
}
