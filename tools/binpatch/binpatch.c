/* binpatch.c */


#include	<stdio.h>				/* printf */
#include	<stdlib.h> 				/* exit */
#include	<string.h>				/* strcmp */

#include	"gendefs.h"
#include	"File.h"
#include	"patch.h"
#include	"patchapply.h"
#include	"binpatch.h"


int main(int argc, char *argv[])
{
	File *patch;					/* patch file */
	PatchArgs args;					/* args structure */


	args = get_args(argc, argv);

	/* open patch file */
	patch = stat_file(args.patch);
	open_file(patch, READONLY_MODE);

	verify_patch_header(patch);

	/* copies diff data from patch file to old/new files */
	apply_patch(patch, args.dir);

	/* close patch file */
	close_file(patch);

	printf("Patch successful\n");

	return SUCCESS;
}

void print_help_message()
{
	fprintf(stderr, "binpat [-d <dir>] <patchfile>\n\n");
	fprintf(stderr, "Applies <patchfile>.\n");
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
