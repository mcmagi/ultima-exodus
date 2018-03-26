#ifndef _FILE_H
#define _FILE_H


#include	<stdio.h>			/* FILE */
#include	<sys/stat.h>		/* struct stat */
#include	<sys/types.h>		/* struct stat */
#include	<unistd.h>			/* struct stat */

#include	"gendefs.h"


/* file data structure */
typedef struct
{
	char *filename;					/* filename */
	FILE *fp;							/* file pointer */
	BOOL newfile;						/* newfile flag */
	struct stat buf;					/* status buffer */
} File;


/* function prototypes */
File *stat_file(const char *filename);
void open_file(File *file, const char open_mode[]);
void reopen_file(File *file, const char open_mode[]);
void close_file(File *file);
void read_from_file(File *file, void *data, size_t size);
void write_to_file(File *file, const void *data, size_t size);
void seek_through_file(File *file, long offset, int seek_type);
BOOL end_of_file(File *file);
void copy_file(File *infile, File *outfile);
void copy_file_n(File *infile, File *outfile, off_t start, size_t size);
void rename_file(File *infile, File *outfile);
void delete_file(File *file);
void truncate_file(File *file, long offset);
long file_size(File *file);
void file_error(const File *file, const char *text);
const char * concat_path(const char *path1, const char *path2);


/* read mode defines */
#define READ_MODE_SZ		4
#define READONLY_MODE		"rb"
#define READWRITE_MODE		"r+b"
#define OVERWRITE_MODE		"w+b"
#define APPEND_MODE			"a+b"


#endif
