/* File.c */

#include	<stdio.h>		/* FILE, fprintf, perror, fopen, fread, fwrite,
							 * fseek, rewind, ftell, fclose, feof, fileno
							 * freopen */
#include	<unistd.h>		/* ftruncate */
#include	<stdlib.h>		/* exit */
#include	<sys/stat.h>	/* stat */
#include	<string.h>		/* strlen, strcpy */
#include	<malloc.h>		/* malloc, free */

#include	"gendefs.h"		/* general use defs */
#include	"File.h"		/* file handling */


/*
 * file handling functions
 */

/* stat the File */
File *stat_file(const char *filename)
{
	File *file;					/* ptr to File structure */


	/* create a new File structure */
	file = (File *) malloc(sizeof(File));

	/* allocate space & copy filename */
	file->filename = (char *) malloc(strlen(filename) + 1);
	strcpy(file->filename, filename);

	/* initialize fp to null */
	file->fp = NULL;

	/* stat the file */
	if (stat(file->filename, &(file->buf)) == FAILURE)
		/* file does not yet exist; it will be new */
		file->newfile = TRUE;
	else
	{
		/* check file size */
		if (file->buf.st_size == 0)
			/* file is 0 bytes; good enough to be new */
			file->newfile = TRUE;
		else
			/* filesize is not 0, therefore it is not new */
			file->newfile = FALSE;
	}

	return file;
}

/* opens a File */
void open_file(File *file, const char open_mode[])
{
	/* open the file */
	if ((file->fp = fopen(file->filename, open_mode)) == NULL)
		file_error(file, "Could not open file");

	/* restat file */
	stat(file->filename, &(file->buf));

	return;
}

void reopen_file(File *file, const char open_mode[])
{
	if ((file->fp = freopen(file->filename, open_mode, file->fp)) == NULL)
		file_error(file, "Could not reopen file");

	return;
}

/* closes a File */
void close_file(File *file)
{
	/* make sure we have actually opened it */
	if (file->fp != NULL)
	{
		/* close the file */
		if (fclose(file->fp) != SUCCESS)
			file_error(file, "Cannot close file");
	}

	/* free space used by filename */
	free(file->filename);

	/* free space used by file */
	free(file);

	return;
}

void read_from_file(File *file, void *data, size_t size)
{
	if (fread(data, size, 1, file->fp) != 1 && ! end_of_file(file))
		file_error(file, "Could not read from file");

	return;
}

void write_to_file(File *file, const void *data, size_t size)
{
	if (fwrite(data, size, 1, file->fp) != 1)
		file_error(file, "Could not write to file");

	return;
}

void seek_through_file(File *file, long offset, int seek_type)
{
	if (fseek(file->fp, offset, seek_type) != SUCCESS)
		file_error(file, "Could not seek through file");

	return;
}

BOOL end_of_file(File *file)
{
	return (BOOL) feof(file->fp);
}

void copy_file(File *infile, File *outfile)
{
	unsigned char *data;
	long size;


	/* get input file size */
	size = file_size(infile);

	/* allocate space for file data */
	data = malloc(size);

	/* seek to beginning of both files */
	rewind(infile->fp);
	rewind(outfile->fp);

	/* read data from infile into memory and write to outfile */
	read_from_file(infile, data, size);
	write_to_file(outfile, data, size);

	/* free space used by data */
	free(data);
}

long file_size(File *file)
{
	long offset;
	long size;
	

	/* save current position in file */
	offset = ftell(file->fp);

	/* advance to end of file */
	seek_through_file(file, 0, SEEK_END);
	size = ftell(file->fp);

	/* reset stream offset */
	seek_through_file(file, offset, SEEK_SET);
}

void truncate_file(File *file, long offset)
{
	if (ftruncate(fileno(file->fp), offset) != SUCCESS)
		file_error(file, "Could not truncate file");
}

/* error handling function */
void file_error(const File *file, const char *text)
{
	/* write to stderr */
	fprintf(stderr, "%s: %s\n", file->filename, text);

	/* do a perror */
	perror(file->filename);

	/* exit */
	exit(FAILURE);
}
