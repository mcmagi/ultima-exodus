#ifndef _BINDIFF_H
#define _BINDIFF_H


#include	"gendefs.h"
#include	"File.h"


#define HELPMSG	1

/* argument structure */
typedef struct
{
	char *oldfile;
	char *newfile;
	char *patchfile;
	BOOL usenew;
    int strip;
} PatchArgs;


/* Function Prototypes */
PatchArgs get_args(int argc, char *argv[]);
void print_help_message();


#endif
