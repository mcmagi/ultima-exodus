#ifndef _DIR_H
#define _DIR_H


#include "File.h"		/* File */
#include "gendefs.h"	/* BOOL */


/* dirlist data structure */
typedef struct {
	int size;
	File **entries;
} DirList;

DirList *list_dir(const File *file, const char *suffix);
BOOL has_suffix(const char *filename, const char *suffix);
void str_to_upper(char *dest, const char *src);
void free_dirlist(DirList *list);


#endif
