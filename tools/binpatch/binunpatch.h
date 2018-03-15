#ifndef _BINUNPATCH_H
#define _BINUNPATCH_H


#include	"gendefs.h"


#define HELPMSG			1

/* argument structure */
typedef struct
{
	char *patch;
    char *dir;
} PatchArgs;


/* Function Prototypes */
void print_help_message();
PatchArgs get_args(int argc, char *argv[]);


#endif
