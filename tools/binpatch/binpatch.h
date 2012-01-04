#ifndef _BINPATCH_H
#define _BINPATCH_H


#include	"gendefs.h"
#include	"File.h"
#include	"patch.h"


#define HELPMSG			1
#define FATAL_ERROR		1

#define REPLACE_TEXT    "replacing"
#define TRUNCATE_TEXT   "truncating"
#define APPEND_TEXT     "appending"

/* argument structure */
typedef struct
{
	char *patch;
    char *dir;
} PatchArgs;


/* Function Prototypes */
void print_help_message();
PatchArgs get_args(int argc, char *argv[]);
void apply_patch(File *patch, const char *dir);
BOOL patch_replace(File *patch, File *old, File *new, struct data_header dz);
BOOL patch_truncate(File *patch, File *new, struct data_header dz);
BOOL patch_append(File *patch, File *new, struct data_header dz);
BOOL compare_old_data(File *patch, File *old, struct data_header dz);
void add_new_data(File *patch, File *new, struct data_header dz);
void patch_message(struct data_header dz);


#endif
