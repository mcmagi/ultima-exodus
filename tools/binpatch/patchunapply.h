#ifndef _PATCH_UNAPPLY_H
#define _PATCH_UNAPPLY_H


#include	"gendefs.h"
#include	"File.h"
#include	"patch.h"


#define UNREPLACE_TEXT  "unreplacing"
#define UNTRUNCATE_TEXT "untruncating"
#define UNAPPEND_TEXT   "unappending"


/* Function Prototypes */
BOOL is_patch_applied(File *patch, const char *dir, BOOL showmsg);
void unapply_patch(File *patch, const char *dir);
BOOL patch_unreplace(File *patch, File *file, struct data_header dz);
BOOL patch_untruncate(File *patch, File *file, struct data_header dz);
BOOL patch_unappend(File *patch, File *file, struct data_header dz);
BOOL compare_new_data(File *patch, File *file, struct data_header dz);
void add_old_data(File *patch, File *file, struct data_header dz);
void unpatch_file_message(struct file_header fz);
void unpatch_data_message(struct data_header dz);


#endif
