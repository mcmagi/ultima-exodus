#ifndef _BINUNPATCH_H
#define _BINUNPATCH_H


#include	"gendefs.h"
#include	"File.h"
#include	"patch.h"


#define HELPMSG			1
#define FATAL_ERROR		1

/* Function Prototypes */
void print_help_message();
void unapply_patch(File *patch);
BOOL patch_unreplace(File *patch, File *file, struct data_header dz);
BOOL patch_untruncate(File *patch, File *file, struct data_header dz);
BOOL patch_unappend(File *patch, File *file, struct data_header dz);
BOOL compare_new_data(File *patch, File *file, struct data_header dz);
void add_old_data(File *patch, File *file, struct data_header dz);


#endif
