/* DirList.c */

#include	<sys/types.h>	/* DIR */
#ifdef __GNUC__
#include	<dirent.h>		/* struct dirent, opendir, readdir, rewinddir, closedir */
#else
#include	<direct.h>		/* struct dirent, opendir, readdir, rewinddir, closedir */
#endif
#include	<ctype.h>		/* toupper */
#include	<malloc.h>		/* malloc, free */
#include	<string.h>		/* strlen, strcpy, strchr */

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
