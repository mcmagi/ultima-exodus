#ifndef _BINDIFF_H
#define _BINDIFF_H


#include	"gendefs.h"
#include	"File.h"


#define		ACTION_COPY			"copy"
#define		ACTION_COPY_ONLY	"copyonly"
#define		ACTION_MOVE			"move"
#define		ACTION_MOVE_ONLY	"moveonly"
#define		ACTION_ADD			"add"

#define HELPMSG	1

/* argument structure */
typedef struct
{
	char *olddir;
	char *oldfile;
	char *newdir;
	char *newfile;
	char *patchfile;
	BOOL nodiff;
	int action;
} PatchArgs;


/* Function Prototypes */
PatchArgs get_args(int argc, char *argv[]);
void print_help_message(const char *error);


#endif
