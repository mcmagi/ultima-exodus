/* binunpatch.c */


#include	<stdio.h>				/* printf, fprintf */
#include	<stdlib.h> 				/* exit */
#include	<string.h>				/* strcmp */

#include	"File.h"
#include	"gendefs.h"
#include	"patch.h"
#include	"patchunapply.h"
#include	"binunpatch.h"


int main(int argc, char *argv[])
{
	File *patch;					/* patch file */
	PatchArgs args;					/* args structure */


	args = get_args(argc, argv);

	/* open patch file */
	patch = stat_file(args.patch);
	open_file(patch, READONLY_MODE);

	printf("Found patch file - verifying\n");
	verify_patch_header(patch);

	/* copies diff data from patch file to old/new files */
	unapply_patch(patch, args.dir);

	/* close patch file */
	close_file(patch);

	printf("Unpatch successful\n");

	return SUCCESS;
}

void print_help_message()
{
	fprintf(stderr, "binunpat [-d <dir>] <patchfile>\n\n");
	fprintf(stderr, "Un-applies <patchfile>.\n");
	fprintf(stderr, " -d <dir>   Directory in which to apply patch\n");
	exit(HELPMSG);
}

PatchArgs get_args(int argc, char *argv[])
{
    PatchArgs args;
	int i;

    /* initialize struct */
    args.patch = NULL;
    args.dir = NULL;

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-h") == MATCH)
			print_help_message();
        else if (strcmp(argv[i], "-d") == MATCH)
			args.dir = argv[++i];
        else
            args.patch = argv[i];
	}

    if (args.patch == NULL)
        print_help_message();

    return args;
}
