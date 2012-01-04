#ifndef _BINUNPATCH_H
#define _BINUNPATCH_H


#include	"gendefs.h"
#include	"File.h"
#include	"patch.h"


#define HELPMSG			1
#define FATAL_ERROR		1

#define UNREPLACE_TEXT  "unreplacing"
#define UNTRUNCATE_TEXT "untruncating"
#define UNAPPEND_TEXT   "unappending"

/* argument structure */
typedef struct
{
	char *patch;
    char *dir;
} PatchArgs;


/* Function Prototypes */
void print_help_message();
PatchArgs get_args(int argc, char *argv[]);
void unapply_patch(File *patch, const char *dir);
BOOL patch_unreplace(File *patch, File *file, struct data_header dz);
BOOL patch_untruncate(File *patch, File *file, struct data_header dz);
BOOL patch_unappend(File *patch, File *file, struct data_header dz);
BOOL compare_new_data(File *patch, File *file, struct data_header dz);
void add_old_data(File *patch, File *file, struct data_header dz);
void unpatch_message(struct data_header dz);


#endif
