/* 
 * File:   filepath.h
 * Author: Michael C. Maggio
 */

#ifndef _FILEPATH_H
#define _FILEPATH_H

/* file parts data structure */
typedef struct
{
	char *dir;				/* path */
	char *name;				/* filename w/o path or extension */
	char *ext;				/* extension */
} FileParts;

/* function prototypes */
void concat_path(char *fullpath, const char *path1, const char *path2);
FileParts * split_filename(const char *filename);
void free_fileparts(FileParts *fp);

#endif /* _FILEPATH_H */
