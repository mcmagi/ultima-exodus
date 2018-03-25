/* patchunapply.c */


#include	<stdio.h>				/* printf */
#include	<stdlib.h> 				/* malloc, free, exit */
#include	<string.h>				/* strncmp, memcmp */

#include	"File.h"
#include	"gendefs.h"
#include	"patch.h"
#include	"patchunapply.h"


BOOL is_patch_applied(File *patch, const char *dir)
{
	char hdrtype[HDR_SZ];				/* holds header type */
	struct file_header fz;				/* header for patched file */
	struct data_header dz;				/* header for patch data */
	File *file = NULL;					/* file handle */
	BOOL mismatch = FALSE;				/* indicates new data mismatch */
	const char *filename;				/* filename */


	/* read first header */
	read_from_file(patch, &hdrtype, HDR_SZ);

	while (! end_of_file(patch))
	{
		/* reset position */
		seek_through_file(patch, -HDR_SZ, SEEK_CUR);

		if (strncmp(hdrtype, FILE_HEADER_ID, HDR_SZ) == MATCH)
		{
			/* close last file's file references (if any) */
			if (file != NULL)
				close_file(file);

			/* read next file header */
			read_from_file(patch, &fz, sizeof(struct file_header));

			/* prepend directory if specified */
			filename = concat_path(dir, fz.action > FA_NONE ? fz.newname : fz.name);

			file = stat_file(filename);

			if (file->newfile)
			{
				mismatch = TRUE;
				break;
			}
			else
			{
				/* open file */
				open_file(file, READONLY_MODE);
			}
		}
		else if (strncmp(hdrtype, DATA_HEADER_ID, HDR_SZ) == MATCH)
		{
			/* read next data header */
			read_from_file(patch, &dz, sizeof(struct data_header));

			/* perform operation based on patch type */
			switch (dz.type)
			{
				case DT_APPEND:
				case DT_REPLACE:
					mismatch = ! compare_new_data(patch, file, dz);
					break;
				case DT_TRUNCATE:
					seek_through_file(patch, dz.size, SEEK_CUR); /* skip */
					break;
			}

			if (mismatch)
				break;
		}
		else
		{
			printf("Unrecognized header information reading patchfile %s\n", patch->filename);
			exit(FATAL_ERROR);
		}

		/* read next header */
		read_from_file(patch, &hdrtype, HDR_SZ);
	}

	/* close file references (if any) */
	if (file != NULL)
		close_file(file);

	return ! mismatch;
}

void unapply_patch(File *patch, const char *dir)
{
	char hdrtype[HDR_SZ];				/* holds header type */
	struct file_header fz;				/* header for patched file */
	struct data_header dz;				/* header for patch data */
	File *file = NULL;					/* file handle */
	BOOL file_error;					/* indicates error during patching */
	BOOL data_error;					/* indicates error during patching */
	int datasize;						/* size of data to skip if error */
	const char *filename;				/* filename */


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
			if (file != NULL)
				close_file(file);

			/* read next file header */
			read_from_file(patch, &fz, sizeof(struct file_header));
			printf("unpatching file %s%s%s\n", fz.name,
					fz.action > FA_NONE ? " <- " : "", fz.newname);

			/* prepend directory if specified */
			filename = concat_path(dir, fz.action > FA_NONE ? fz.newname : fz.name);

			file = stat_file(filename);

			if (file->newfile)
			{
				printf("File not found '%s'", file->filename);
				file_error = TRUE;
			}
			else
			{
				/* open file */
				open_file(file, READWRITE_MODE);
			}
		}
		else if (strncmp(hdrtype, DATA_HEADER_ID, HDR_SZ) == MATCH)
		{
			/* read next data header */
			//printf("read data header\n");
			read_from_file(patch, &dz, sizeof(struct data_header));

			if (! file_error)
			{
				unpatch_message(dz);

				/* perform operation based on patch type */
				switch (dz.type)
				{
					case DT_APPEND:
						data_error = patch_unappend(patch, file, dz);
						break;
					case DT_TRUNCATE:
						data_error = patch_untruncate(patch, file, dz);
						break;
					case DT_REPLACE:
						data_error = patch_unreplace(patch, file, dz);
						break;
				}

				if (data_error)
				{
					printf("patched data did not match in file %s at offset %d\n",
							file->filename, dz.offset);
				}
			}
			else
			{
				//printf("file_error; skipping data\n");

				/* skip over data */
				datasize = dz.size;
				if (dz.type == DT_REPLACE)
					datasize *= 2;

				seek_through_file(patch, datasize, SEEK_CUR);
			}
		}
		else
		{
			printf("Unrecognized header information reading patchfile %s\n", patch->filename);
			exit(FATAL_ERROR);
		}

		/* read next header */
		read_from_file(patch, &hdrtype, HDR_SZ);
	}

	/* close file references (if any) */
	if (file != NULL)
		close_file(file);
}

BOOL patch_unreplace(File *patch, File *file, struct data_header dz)
{
	/* compares if data matches */
	if (! compare_new_data(patch, file, dz))
		return TRUE;

	/* return to start of old data in patch */
	seek_through_file(patch, -(2*dz.size), SEEK_CUR);

	/* if match, replaces data in file */
	add_old_data(patch, file, dz);

	/* advance to end of new data / next header */
	seek_through_file(patch, dz.size, SEEK_CUR);

	return FALSE;
}

BOOL patch_untruncate(File *patch, File *file, struct data_header dz)
{
	/* just appends data to file */
	add_old_data(patch, file, dz);

	return FALSE;
}

BOOL patch_unappend(File *patch, File *file, struct data_header dz)
{
	/* compares if data matches */
	if (! compare_new_data(patch, file, dz))
		return TRUE;

	/* truncate file */
	truncate_file(file, dz.offset);

	return FALSE;
}

BOOL compare_new_data(File *patch, File *file, struct data_header dz)
{
	unsigned char *newdata = NULL;		/* data to replace */
	unsigned char *cmpdata = NULL;		/* data to compare */
	BOOL match = FALSE;					/* set if they don't match */


	/* skip over old data in patch (if present) */
	if (dz.type == DT_REPLACE)
		seek_through_file(patch, dz.size, SEEK_CUR);

	/* read new data that was replaced from patch file */
	newdata = malloc(dz.size);
	read_from_file(patch, newdata, dz.size);

	/* read data to replace from old file to compare */
	cmpdata = malloc(dz.size);
	seek_through_file(file, dz.offset, SEEK_SET);
	read_from_file(file, cmpdata, dz.size);

	/* compare data */
	if (memcmp(newdata, cmpdata, dz.size) == MATCH)
		match = TRUE;

	/* free up old / cmp data areas */
	free(cmpdata);
	free(newdata);

	return match;
}

void add_old_data(File *patch, File *file, struct data_header dz)
{
	unsigned char *olddata = NULL;		/* data to apply */


	/* read original data from patch file */
	olddata = malloc(dz.size);
	read_from_file(patch, olddata, dz.size);

	/* write replacement data to new file */
	seek_through_file(file, dz.offset, SEEK_SET);
	write_to_file(file, olddata, dz.size);
}


void unpatch_message(struct data_header dz)
{
	const char *typetext = NULL;

	if (dz.type == DT_REPLACE)
		typetext = UNREPLACE_TEXT;
	else if (dz.type == DT_TRUNCATE)
		typetext = UNTRUNCATE_TEXT;
	else if (dz.type == DT_APPEND)
		typetext = UNAPPEND_TEXT;

	if (typetext != NULL)
	{
		printf(" -> %s %d bytes", typetext, dz.size);
		printf(" at offset %d\n", dz.offset); /* bug in openwatcom? second long param shows as 0; need second printf */
	}

	return;
}
