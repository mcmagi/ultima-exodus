/* DirList.c */

#include	<sys/types.h>	/* DIR */
#ifdef __GNUC__
#include	<dirent.h>		/* struct dirent, opendir, readdir, rewinddir, closedir */
#else
#include	<direct.h>		/* struct dirent, opendir, readdir, rewinddir, closedir */
#endif
#include	<ctype.h>		/* toupper */
#include	<malloc.h>		/* malloc, free */
#include	<string.h>		/* strlen, strcpy */

#include	"gendefs.h"		/* general use defs */
#include	"File.h"		/* file handling */
#include	"DirList.h"		/* dir list handling */


/*
 * Directory Listing Functions
 */

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

#ifdef __GNUC__
	rewinddir(dp);
#else
	/* watcom supports rewinddir in dos, winnt, but it won't link in linux */
	closedir(dp);
	if ((dp = opendir(file->filename)) == NULL)
		file_error(file, "Could not open directory");
#endif

	list->entries = malloc(sizeof(File *) * list->size);

	/* now get all filenames */
	while ((dir = readdir(dp)) != NULL)
	{
		if (suffix == NULL || has_suffix(dir->d_name, suffix))
		{
			list->entries[i++] = stat_file(dir->d_name);
		}
	}

	/* update filtered dir list size */
	list->size = i;

	closedir(dp);

	return list;
}

BOOL has_suffix(const char *filename, const char *suffix)
{
	char filename_upper[256];
	char suffix_upper[256];
	int suffix_idx;

	str_to_upper(filename_upper, filename);
	str_to_upper(suffix_upper, suffix);

	suffix_idx = strlen(filename_upper) - strlen(suffix);

	/* compare file extension */
	return strcmp(&filename_upper[suffix_idx], suffix_upper) == MATCH;
}

void str_to_upper(char *dest, const char *src)
{
	int i = 0;
	for (i = 0; src[i] != '\0'; i++)
		dest[i] = toupper(src[i]);
	dest[i] = '\0';
}

/* frees all memory associated with a DirList */
void free_dirlist(DirList *list)
{
	int i = 0;

	/* close all file entries */
	for (i = 0; i < list->size; i++)
		close_file(list->entries[i]);

	/* free array */
	free(list->entries);

	/* free struct */
	free(list);
}
