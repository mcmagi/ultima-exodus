#ifndef _BINPATCH_H
#define _BINPATCH_H


#include	"gendefs.h"
#include	"File.h"


#define HELPMSG			1
#define FATAL_ERROR		1

/* Function Prototypes */
void print_help_message();
void apply_patch(File *patch);
BOOL patch_replace(File *patch, File *old, File *new, struct data_header dz);
BOOL patch_truncate(File *patch, File *new, struct data_header dz);
BOOL patch_append(File *patch, File *new, struct data_header dz);
BOOL compare_old_data(File *patch, File *old, struct data_header dz);
void add_new_data(File *patch, File *new, struct data_header dz);


#endif
