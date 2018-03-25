#ifndef _PATCHADD_H
#define _PATCHADD_H


#include	"gendefs.h"
#include	"File.h"
#include    "patch.h"


/* Function Prototypes */
int diff(const char oldfile[], const char newfile[], File *patch, int action, int strip);
long patch_add_append(File *new, File *patch, long idx);
long patch_add_truncate(File *old, File *patch, long idx);
long patch_add_replace(File *old, File *new, File *patch, long idx);
long patch_add_one(File *in, File *patch, long idx, int type);
long get_replace_size(File *old, File *new, long offset);
void create_patch_file(File *patch, struct file_header fz);
void write_patch_header(File *patch, long size);
const char * strip_path(const char *path, int strip);


#endif
