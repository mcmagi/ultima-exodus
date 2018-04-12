/* binpatch.c */


#include	<stdio.h>				/* printf, fprintf */
#include	<stdlib.h> 				/* malloc, free, exit */
#include	<string.h>				/* strncmp, memcmp */

#include	"File.h"
#include	"gendefs.h"
#include	"patch.h"
#include	"binpatch.h"


int main(int argc, char *argv[])
{
	char *filename;					/* patch filename */
	File *patch;					/* patch file */


	if (argc == 1)
		print_help_message();

	filename = argv[1];

	/* open patch file */
	patch = stat_file(filename);
	open_file(patch, READONLY_MODE);

	verify_patch_header(patch);

	/* copies diff data from patch file to old/new files */
	apply_patch(patch);

	/* close patch file */
	close_file(patch);

	printf("Patch successful\n");

	return;
}

void print_help_message()
{
	fprintf(stderr, "binpatch <patchfile>\n\n");
	fprintf(stderr, "Applies <patchfile>.\n");
	exit(HELPMSG);
}

void apply_patch(File *patch)
{
	const char hdrtype[HDR_SZ];			/* holds header type */
	struct file_header fz;				/* header for patched file */
	struct data_header dz;				/* header for patch data */
	File *old = NULL, *new = NULL;		/* input/output file handles */
	BOOL file_error;					/* indicates error during patching */
	BOOL data_error;					/* indicates error during patching */


	/* read first header */
	read_from_file(patch, &hdrtype, HDR_SZ);

	while (! end_of_file(patch))
	{
		/* reset position */
		seek_through_file(patch, -HDR_SZ, SEEK_CUR);

		if (strncmp(hdrtype, FILE_HEADER_ID, HDR_SZ) == MATCH)
		{
			file_error = FALSE;

			/* close last file's file references (if any) */
			if (old != NULL)
				close_file(old);
			if (new != NULL && fz.newname_flag)
				close_file(new);

			/* read next file header */
			read_from_file(patch, &fz, sizeof(struct file_header));
			printf("patching file %s%s%s\n", fz.name,
					fz.newname_flag ? " -> " : "", fz.newname);

			old = stat_file(fz.name);

			if (fz.size != old->buf.st_size)
			{
				printf("File not found or size mismatch on file '%s';"
						"found %d expected %d\n", old->filename,
						old->buf.st_size, fz.size);
				file_error = TRUE;
				continue;
			}

			if (fz.newname_flag)
			{
				/* open old file */
				open_file(old, READONLY_MODE);

				/* open new file */
				new = stat_file(fz.newname);
				open_file(new, READWRITE_MODE);

				/* copy file (from old to new) */
				copy_file(old, new);
			}
			else
			{
				/* open only one file */
				open_file(old, READWRITE_MODE);

				/* the newfile is the oldfile */
				new = old;
			}
		}
		else if (! file_error && strncmp(hdrtype, DATA_HEADER_ID, HDR_SZ) == MATCH)
		{
			/* read next data header */
			//printf("read data header\n");
			read_from_file(patch, &dz, sizeof(struct data_header));

			/* perform operation based on patch type */
			switch (dz.type)
			{
				case DT_APPEND:
					data_error = patch_append(patch, new, dz);
					break;
				case DT_TRUNCATE:
					data_error = patch_truncate(patch, old, dz);
					break;
				case DT_REPLACE:
					data_error = patch_replace(patch, old, new, dz);
					break;
			}

			if (data_error)
			{
				printf("original data did not match in file %s at offset %d\n",
						old->filename, dz.offset);
			}
		}
		else
		{
			printf("Unrecognized header information reading patchfile\n");
			exit(FATAL_ERROR);
		}

		/* read next header */
		read_from_file(patch, &hdrtype, HDR_SZ);
	}

	/* close file references (if any) */
	if (old != NULL)
		close_file(old);
	if (new != NULL && fz.newname_flag)
		close_file(new);
}

BOOL patch_replace(File *patch, File *old, File *new, struct data_header dz)
{
	//printf("replacing...\n");

	/* compares if data matches */
	if (! compare_old_data(patch, old, dz))
		return TRUE;

	/* if match, replaces data in file */
	add_new_data(patch, new, dz);

	return FALSE;
}

BOOL patch_truncate(File *patch, File *old, struct data_header dz)
{
	//printf("truncating...\n");

	/* compares if data matches */
	if (! compare_old_data(patch, old, dz))
		return TRUE;

	/* truncate file */
	truncate_file(old, dz.offset);

	return FALSE;
}

BOOL patch_append(File *patch, File *new, struct data_header dz)
{
	//printf("appending...\n");

	/* just appends data to file */
	add_new_data(patch, new, dz);

	return FALSE;
}

BOOL compare_old_data(File *patch, File *old, struct data_header dz)
{
	unsigned char *olddata = NULL;		/* data to replace */
	unsigned char *cmpdata = NULL;		/* data to compare */
	BOOL match = FALSE;					/* set if they don't match */


	/* read data to replace from patch file */
	olddata = malloc(dz.size);
	read_from_file(patch, olddata, dz.size);

	/* read data to replace from old file to compare */
	cmpdata = malloc(dz.size);
	seek_through_file(old, dz.offset, SEEK_SET);
	read_from_file(old, cmpdata, dz.size);

	/* compare data */
	if (memcmp(olddata, cmpdata, dz.size) == MATCH)
		match = TRUE;

	/* free up old / cmp data areas */
	free(cmpdata);
	free(olddata);

	return match;
}

void add_new_data(File *patch, File *new, struct data_header dz)
{
	unsigned char *newdata = NULL;		/* data to apply */


	/* read replacement data from patch file */
	newdata = malloc(dz.size);
	read_from_file(patch, newdata, dz.size);

	/* write replacement data to new file */
	seek_through_file(new, dz.offset, SEEK_SET);
	write_to_file(new, newdata, dz.size);
}
