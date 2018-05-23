#ifndef _PATCH_H
#define _PATCH_H


#include	"gendefs.h"
#include	"File.h"
#include	"List.h"


/* error codes */
#define FATAL_ERROR		1

/* definitions */
#define	DT_REPLACE	0
#define	DT_APPEND	1
#define	DT_TRUNCATE	2

#define	FA_NONE		0
#define	FA_COPY		1
#define	FA_RENAME	2
#define	FA_ADD		3

#define PATCH_HEADER_ID	"PZ"
#define FILE_HEADER_ID	"FZ"
#define DATA_HEADER_ID	"DZ"

#define PATCH_VER	'1'
#define FILE_VER	'1'
#define DATA_VER	'1'

#define	FT_NAME_SZ	64
#define	HDR_SZ		2


/* data structures */
struct patch_header
{
	char hdr[HDR_SZ];			/* PZ */
	char ver;					/* version 1 */
	long size;					/* patch size */
};

struct file_header
{
	char hdr[HDR_SZ];			/* FZ */
	char ver;					/* version 1 */
	char name[FT_NAME_SZ];		/* file name */
	char newname[FT_NAME_SZ];	/* suggested new filename */
	char action;				/* file action = one of FA_* values */
	long size;					/* file size */
};

struct data_header
{
	char hdr[HDR_SZ];			/* DZ */
	char ver;					/* version 2 */
	long offset;				/* data offset */
	long size;					/* data size */
	short type;					/* data type = one of DT_* values */
	short _padding;				/* must end on dword boundry */
};


/* Function Prototypes */
struct patch_header build_patch_header(long size);
struct file_header build_file_header(const char filename[], const char newname[], int action, long size);
struct data_header build_data_header(long offset, long size, short type);
void set_filename(char *out, const char *in);
void verify_patch_header(File *patch);
List * build_patch_index(File *patch);
void patch_index_add(List *fzIndex, long value);
long patch_index_get(List *fzIndex, int idx);


#endif
