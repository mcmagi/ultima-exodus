#ifndef _BINDIFF_H
#define _BINDIFF_H


#include	"gendefs.h"
#include	"File.h"


#define		ACTION_COPY		"copy"
#define		ACTION_RENAME	"rename"
#define		ACTION_CREATE	"create"

#define HELPMSG	1

/* argument structure */
typedef struct
{
	char *olddir;
	char *oldfile;
	char *newdir;
	char *newfile;
	char *patchfile;
	int action;
    int strip;
} PatchArgs;


/* Function Prototypes */
PatchArgs get_args(int argc, char *argv[]);
void print_help_message(const char *error);


#endif
