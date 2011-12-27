#ifndef _PATCHADD_H
#define _PATCHADD_H


#include	"gendefs.h"
#include	"File.h"


/* Function Prototypes */
void diff(const char oldfile[], const char newfile[], File *patch, BOOL newflag);
long patch_add_append(File *new, File *patch, long idx);
long patch_add_truncate(File *old, File *patch, long idx);
long patch_add_replace(File *old, File *new, File *patch, long idx);
long patch_add_one(File *in, File *patch, long idx, int type);
long get_replace_size(File *old, File *new, long offset);


#endif
