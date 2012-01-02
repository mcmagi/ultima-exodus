/* patchadd.c */


#include	<malloc.h>
#include	<string.h>

#include	"File.h"
#include	"gendefs.h"
#include	"patch.h"
#include	"patchadd.h"


/* DIFF Functions */

int diff(const char oldfile[], const char newfile[], File *patch, BOOL newflag)
{
	unsigned char oldbyte, newbyte;		/* storage for old and new bytes */
	int idx;							/* index into file */
	int max_idx;						/* max index */
	struct file_header fz;				/* file header */
	File *old;							/* ptr to old file */
	File *new;							/* ptr to new file */
	const char *newname = NULL;			/* ptr to new filename */
    int diffcount = 0;                  /* number of differences found */


	/* stat files */
	old = stat_file(oldfile);
	new = stat_file(newfile);

	/* open files */
	open_file(old, READONLY_MODE);
	open_file(new, READONLY_MODE);

	/* determine if we will use the new filename */
	if (newflag)
		newname = newfile;

    /* create file header; wait to write it until we find our first difference */
	fz = build_file_header(oldfile, newname, old->buf.st_size);

    if (patch->fp != NULL)
    {
	    /* write file header to patch file if file exists */
    }

	/* loop through lower of two sizes */
	max_idx = (old->buf.st_size > new->buf.st_size) ? new->buf.st_size : old->buf.st_size;

	/* loop through file until max_size is reached */
	for (idx = 0; idx < max_idx; idx++)
	{
		/* read a byte from both files */
		read_from_file(old, &oldbyte, sizeof(unsigned char));
		read_from_file(new, &newbyte, sizeof(unsigned char));

		/* check if we have a difference */
		if (oldbyte != newbyte)
		{
			//printf("\noffset %d: differ (%x, %x)\n", ftell(old->fp), oldbyte, newbyte);

			/* found difference - must replace
			 *  (and offset current index by patched data size) */

            /* first diff found; write patch header and/or file header */
            if (patch->fp == NULL)
                create_patch_file(patch, fz);
            else if (diffcount == 0)
	            write_to_file(patch, &fz, sizeof(fz));

			idx += patch_add_replace(old, new, patch, idx) - 1;
            diffcount++;
		}
	}

	/* determine if the file sizes are not equal */
	if (old->buf.st_size > new->buf.st_size)
    {
		/* old file greater than new file - must truncate */

        /* first diff found; write patch header and/or file header */
        if (patch->fp == NULL)
            create_patch_file(patch, fz);
        else if (diffcount == 0)
            write_to_file(patch, &fz, sizeof(fz));

		patch_add_truncate(old, patch, idx);
        diffcount++;
    }
	else if (old->buf.st_size < new->buf.st_size)
    {
		/* new file greater than old file - must append */

        /* first diff found; write patch header and/or file header */
        if (patch->fp == NULL)
            create_patch_file(patch, fz);
        else if (diffcount == 0)
            write_to_file(patch, &fz, sizeof(fz));

		patch_add_append(new, patch, idx);
        diffcount++;
    }

	if (diffcount == 0)
		printf("Files %s and %s are identical\n", old->filename, new->filename);

	/* close files */
	close_file(old);
	close_file(new);

    return diffcount;
}


/* Patch Add functions */

/* applies all data in new file from current index through EOF to patch */
long patch_add_append(File *new, File *patch, long idx)
{
	//printf("append\n");
	return patch_add_one(new, patch, idx, DT_APPEND);
}

/* applies all data in old file from current index through EOF to patch */
long patch_add_truncate(File *old, File *patch, long idx)
{
	//printf("truncate\n");
	return patch_add_one(old, patch, idx, DT_TRUNCATE);
}

/* applies all data from current index through EOF to patch */
long patch_add_one(File *in, File *patch, long idx, int type)
{
	unsigned char *data;				/* ptrs to mem for data */
	struct data_header dz;				/* data header */
	int data_size;						/* data size */


	/* get size of data */
	data_size = in->buf.st_size - idx;

	/* build data header */
	dz = build_data_header(idx, data_size, type);

	/* allocate space for new data */
	data = malloc(data_size);

	/* read new data from file */
	seek_through_file(in, idx, SEEK_SET);
	read_from_file(in, data, dz.size);

	/* write header and data to patch file */
	write_to_file(patch, &dz, sizeof(struct data_header));
	write_to_file(patch, data, dz.size);

	/* free memory */
	free(data);

	return data_size;
}

/* applies data from old and new files to patch */
long patch_add_replace(File *old, File *new, File *patch, long idx)
{
	unsigned char *olddata, *newdata;	/* ptrs to mem for old/new data */
	struct data_header dz;				/* data header */
	int data_size;						/* data size */


	//printf("replace\n");

	/* get size of data */
	data_size = get_replace_size(old, new, idx);

	/* build data header */
	dz = build_data_header(idx, data_size, DT_REPLACE);

	/* allocate space for old and new data */
	olddata = malloc(data_size);
	newdata = malloc(data_size);

	/* read old data from file */
	seek_through_file(old, idx, SEEK_SET);
	read_from_file(old, olddata, dz.size);

	/* read new data from file */
	seek_through_file(new, idx, SEEK_SET);
	read_from_file(new, newdata, dz.size);

	/* write header and data to patch file */
	write_to_file(patch, &dz, sizeof(struct data_header));
	write_to_file(patch, olddata, dz.size);
	write_to_file(patch, newdata, dz.size);

	/* free memory */
	free(olddata);
	free(newdata);

	/* return size of data patched */
	return data_size;
}

long get_replace_size(File *old, File *new, long offset)
{
	unsigned char oldbyte, newbyte;		/* old and new bytes */
	int bytes = -1;						/* byte counter */
	BOOL eof, differ;					/* loop flags */


	/* seek to specified offset */
	seek_through_file(old, offset, SEEK_SET);
	seek_through_file(new, offset, SEEK_SET);

	//printf("at position %d in %s\n", offset, old->filename);

	/* count each byte that is different */
	do
	{
		/* count number of bytes */
		bytes++;

		/* get bytes from files */
		read_from_file(old, &oldbyte, sizeof(unsigned char));
		read_from_file(new, &newbyte, sizeof(unsigned char));

		differ = (BOOL) oldbyte != newbyte;
		eof = end_of_file(old) || end_of_file(new);
	}
	while (differ && ! eof);

	//printf("offset %d: same (%x, %x)\n", offset, oldbyte, newbyte);
	//printf("%d bytes differ\n", bytes);

	/* return to specified offset */
	seek_through_file(old, offset, SEEK_SET);
	seek_through_file(new, offset, SEEK_SET);

	return bytes;
}

void create_patch_file(File *patch, struct file_header fz)
{
	printf("New patch file - creating\n");
	open_file(patch, APPEND_MODE);

	write_patch_header(patch, sizeof(struct patch_header));

    /* write file header to patch file */
    write_to_file(patch, &fz, sizeof(fz));
}

void write_patch_header(File *patch, long size)
{
	struct patch_header pz;

	pz = build_patch_header(size);
	seek_through_file(patch, 0, SEEK_SET);
	write_to_file(patch, &pz, sizeof(struct patch_header));
}
