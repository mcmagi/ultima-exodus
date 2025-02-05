#ifndef _PATCH_APPLY_H
#define _PATCH_APPLY_H


#include	"gendefs.h"
#include	"File.h"
#include	"patch.h"


#define REPLACE_TEXT    "replacing"
#define TRUNCATE_TEXT   "truncating"
#define APPEND_TEXT     "appending"


/* Function Prototypes */
BOOL is_patch_unapplied(File *patch, const char *dir, BOOL showmsg);
void apply_patch(File *patch, const char *dir);
BOOL patch_replace(File *patch, File *old, File *new, struct data_header dz);
BOOL patch_truncate(File *patch, File *new, struct data_header dz);
BOOL patch_append(File *patch, File *new, struct data_header dz);
BOOL compare_old_data(File *patch, File *old, struct data_header dz);
void add_new_data(File *patch, File *new, struct data_header dz);
void patch_file_message(struct file_header fz);
void patch_data_message(struct data_header dz);


#endif
