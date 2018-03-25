/* bindiff.c */


#include	<stdio.h>				/* fprintf, printf */
#include	<stdlib.h>				/* exit, atoi */
#include	<string.h>				/* strcmp */

#include	"File.h"
#include	"gendefs.h"
#include	"patch.h"
#include	"patchadd.h"
#include	"bindiff.h"


int main(int argc, char *argv[])
{
	File *patch;					/* patch file */
	PatchArgs args;					/* args structure */
    int num_diffs;                  /* number of differences found */


	args = get_args(argc, argv);

	/* open patch file */
	patch = stat_file(args.patchfile);

	/* verify patch header */
	if (! patch->newfile)
	{
	    open_file(patch, APPEND_MODE);

		printf("Found existing file - verifying\n");
		verify_patch_header(patch);

		/* seek to end of file */
		seek_through_file(patch, 0, SEEK_END);
	}

	/* copies diff data from old/new files to patch file */
	num_diffs = diff(args.oldfile, args.newfile, patch, args.action, args.strip);

    if (num_diffs > 0)
    {
	    /* write patch header with updated size */
        int newsize = file_size(patch);

        /* must reopen to write to beginning of file */
        reopen_file(patch, READWRITE_MODE);
	    write_patch_header(patch, newsize);

	    printf("patch file '%s', size %d, number of differences %d\n", patch->filename, newsize, num_diffs);
    }
    else
    {
	    printf("no differences found\n");
    }


	close_file(patch);

	return SUCCESS;
}

/* fills PatchArgs structure */
PatchArgs get_args(int argc, char *argv[])
{
	PatchArgs args;
	int i;
    char *error;


	/* initialize struct */
    args.oldfile = NULL;
    args.newfile = NULL;
    args.patchfile = NULL;
	args.action = FA_NONE;
    args.strip = 0;

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-h") == MATCH)
			print_help_message(NULL);
		if (strcmp(argv[i], "-a") == MATCH)
		{
			if (strcmp(argv[++i], ACTION_COPY) == MATCH)
				args.action = FA_COPY;
			else if (strcmp(argv[i], ACTION_RENAME) == MATCH)
				args.action = FA_RENAME;
			else if (strcmp(argv[i], ACTION_CREATE) == MATCH)
				args.action = FA_CREATE;
			else
				print_help_message("allowed actions: copy, rename, create");
		}
		else /* (i != argc) */
		{
			if (strcmp(argv[i], "-o") == MATCH)
				args.oldfile = argv[++i];
			else if (strcmp(argv[i], "-n") == MATCH)
				args.newfile = argv[++i];
			else if (strcmp(argv[i], "-p") == MATCH)
				args.patchfile = argv[++i];
			else if (strcmp(argv[i], "-s") == MATCH)
				args.strip = atoi(argv[++i]);
			else
				print_help_message("unrecognized argument");
		}
	}

	if (args.oldfile == NULL)
		error = "old (source) file is required";
	if (args.newfile == NULL)
		error = "new (target) file is required";
	if (args.patchfile == NULL)
		error = "patch file is required";

	if (error != NULL)
		print_help_message(error);

	return args;
}

void print_help_message(const char *error)
{
	if (error != NULL)
		fprintf(stderr, "ERROR: %s\n\n", error);
	fprintf(stderr, "bindiff [-a <action>] [-s <num>] -o <oldfile> -n <newfile> -p <patchfile>\n\n");
	fprintf(stderr, "Compares <oldfile> and <newfile>, applying difference to <patchfile>.\n");
	fprintf(stderr, "\t-u\tAction to take when applying patch: copy, rename, create\n");
	fprintf(stderr, "\t-s\tStrip <num> leading path components from file name\n\n");
	fprintf(stderr, "\t-o\tName of old (or source) file\n");
	fprintf(stderr, "\t-n\tName of new (or target) file\n");
	fprintf(stderr, "\t-p\tName of patchfile\n");
	exit(HELPMSG);
}
