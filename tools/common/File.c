/* File.c */

#include	<stdio.h>		/* FILE, fprintf, perror, fopen, fread, fwrite,
							 * fseek, rewind, ftell, fclose, feof, fileno
							 * freopen */
#include	<unistd.h>		/* ftruncate */
#include	<stdlib.h>		/* exit */
#include	<sys/stat.h>	/* stat */
#include	<sys/types.h>	/* readdir */
#include	<string.h>		/* strlen, strcpy, strchr */
#include	<malloc.h>		/* malloc, free */
#ifdef __GNUC__
#include	<dirent.h>		/* opendir, readdir, rewinddir, closedir */
#else
#include	<direct.h>		/* opendir, readdir, rewinddir, closedir */
#endif
#include	<ctype.h>		/* toupper */

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
	long size;


	/* get input file size */
	size = file_size(infile);
    copy_file_n(infile, outfile, 0, size);
}

void copy_file_n(File *infile, File *outfile, off_t start, size_t size)
{
	unsigned char *data;


	/* allocate space for file data */
	data = malloc(size);

	/* seek to starting offset of infile, beginning of both outfile */
    seek_through_file(infile, start, SEEK_SET);
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

    return size;
}

void truncate_file(File *file, long offset)
{
#ifdef __GNUC__
	if (ftruncate(fileno(file->fp), offset) != SUCCESS)
		file_error(file, "Could not truncate file");
#else
    /* ftruncate is not defined in OpenWatcom,
     * so the strategy is to read the data into memory, reopen the file, and rewrite */

    unsigned char *data;


    /* ftruncate() preserves the seek cursor */
    int current_offset = ftell(file->fp);

    /* read the file data up to offset */
    rewind(file->fp);
    data = malloc(offset);
    read_from_file(file, data, offset);

	/* reopen the file */
    reopen_file(file, OVERWRITE_MODE);

    /* rewrite the truncated file data */
    write_to_file(file, data, offset);
    free(data);

    /* restore seek cursor; constrain by new file size */
    seek_through_file(file, current_offset > offset ? offset : current_offset, SEEK_SET);
#endif
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

/* concatenates two path elements */
const char * concat_path(const char *path1, const char *path2)
{
    static char filename[BUFSIZ];
    int i = 0;

    if (path1 != NULL && strlen(path1) > 0)
    {
        strcpy(filename, path1);
        i = strlen(path1);

        /* insert directory separator if both paths are specified */
        if (path2 != NULL && strlen(path2) > 0)
        {
            if (filename[i] != '/' || filename[i] != '\\')
                filename[i++] = '/';
        }
    }

    if (path2 != NULL && strlen(path2) > 0)
        strcpy(&filename[i], path2);

    return filename;
}

/* reads the contents of a directory */
DirList *list_dir(const File *file, const char *suffix)
{
	DIR *dp;
	struct dirent *dir;
	DirList *list;
	int i = 0;

	/* open the directory */
	if ((dp = opendir(file->filename)) == NULL)
		file_error(file, "Could not open directory");

	list = malloc(sizeof(DirList));

	/* count number of files in directory */
	while ((dir = readdir(dp)) != NULL)
	{
		if (suffix == NULL || has_suffix(dir->d_name, suffix))
			list->size++;
	}
	rewinddir(dp);

	list->entries = malloc(sizeof(char *) * list->size);

	/* now get all filenames */
	while ((dir = readdir(dp)) != NULL)
	{
		if (suffix == NULL || has_suffix(dir->d_name, suffix))
		{
			list->entries[i] = malloc(sizeof(char) * strlen(dir->d_name) + 1);
			strcpy(list->entries[i++], dir->d_name);
		}
	}

	closedir(dp);

	return list;
}

BOOL has_suffix(const char *filename, const char *suffix)
{
	char filename_upper[30];
	char suffix_upper[30];
	char *dot_ptr;

	str_to_upper(filename_upper, filename);
	str_to_upper(suffix_upper, suffix);

	dot_ptr = strchr(filename_upper, '.');

	/* compare file extension */
	return dot_ptr == NULL ? FALSE :
		strcmp(&dot_ptr[1], suffix_upper) == 0;
}

void str_to_upper(char *dest, const char *src)
{
	int i = 0;
	for (i = 0; src[i] != '\0'; i++)
		dest[i] = toupper(src[i]);
}

/* frees all memory associated with a DirList */
void free_dirlist(DirList *list)
{
	int i = 0;

	/* free all filename entries */
	for (i = 0; i < list->size; i++)
		free(list->entries[i]);

	/* free array */
	free(list->entries);

	/* free struct */
	free(list);
}
