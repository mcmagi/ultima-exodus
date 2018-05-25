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
	int num_diffs;					/* number of differences found */


	args = get_args(argc, argv);

	/* open patch file */
	patch = stat_file(args.patchfile);

	/* verify patch header */
	if (! patch->newfile)
	{
		open_file(patch, APPEND_MODE);

		verify_patch_header(patch);

		/* seek to end of file */
		seek_through_file(patch, 0, SEEK_END);
	}

	/* copies diff data from old/new files to patch file */
	num_diffs = diff(args.olddir, args.oldfile, args.newdir, args.newfile, patch, args.action, args.nodiff);

	if (num_diffs > 0)
	{
		/* write patch header with updated size */
		int newsize = file_size(patch);

		/* must reopen to write to beginning of file */
		reopen_file(patch, READWRITE_MODE);
		write_patch_header(patch, newsize);

		printf("%s: %d differences found -> %s (size %d)\n", args.oldfile == NULL ? args.newfile : args.oldfile, num_diffs, patch->filename, newsize);
	}
	else
	{
		printf("%s: 0 differences found\n", args.oldfile == NULL ? args.newfile : args.oldfile);
	}


	close_file(patch);

	return SUCCESS;
}

/* fills PatchArgs structure */
PatchArgs get_args(int argc, char *argv[])
{
	PatchArgs args;
	int i;
	char *error = NULL;


	/* initialize struct */
	args.olddir = NULL;
	args.oldfile = NULL;
	args.newdir = NULL;
	args.newfile = NULL;
	args.patchfile = NULL;
	args.action = FA_NONE;
	args.nodiff = FALSE;

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-h") == MATCH)
			print_help_message(NULL);
		if (strcmp(argv[i], "-a") == MATCH)
		{
			if (strcmp(argv[++i], ACTION_COPY) == MATCH)
				args.action = FA_COPY;
			else if (strcmp(argv[i], ACTION_COPY_ONLY) == MATCH)
			{
				args.action = FA_COPY;
				args.nodiff = TRUE;
			}
			else if (strcmp(argv[i], ACTION_MOVE) == MATCH)
				args.action = FA_RENAME;
			else if (strcmp(argv[i], ACTION_MOVE_ONLY) == MATCH)
			{
				args.action = FA_RENAME;
				args.nodiff = TRUE;
			}
			else if (strcmp(argv[i], ACTION_ADD) == MATCH)
				args.action = FA_ADD;
			else if (strcmp(argv[i], ACTION_REPLACE) == MATCH)
				args.action = FA_REPLACE;
			else
				print_help_message("allowed actions: copy, copyonly, move, moveonly, add, replace");
		}
		else /* (i != argc) */
		{
			if (strcmp(argv[i], "-od") == MATCH)
				args.olddir = argv[++i];
			else if (strcmp(argv[i], "-o") == MATCH)
				args.oldfile = argv[++i];
			else if (strcmp(argv[i], "-nd") == MATCH)
				args.newdir = argv[++i];
			else if (strcmp(argv[i], "-n") == MATCH)
				args.newfile = argv[++i];
			else if (strcmp(argv[i], "-p") == MATCH)
				args.patchfile = argv[++i];
			else
				print_help_message("unrecognized argument");
		}
	}

	if (args.oldfile == NULL && args.action != FA_ADD)
		error = "old (source) file is required";
	else if (args.oldfile != NULL && args.action == FA_ADD)
		error = "old (source) file cannot be used for add action";

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
	fprintf(stderr, "bindiff [-a %s|%s|%s|%s|%s] [-od <olddir>] -o <oldfile> [-nd <newdir>] -n <newfile> -p <patchfile>\n",
			ACTION_COPY, ACTION_COPY_ONLY, ACTION_MOVE, ACTION_MOVE_ONLY, ACTION_REPLACE);
	fprintf(stderr, "bindiff -a %s [-nd <newdir>] -n <newfile> -p <patchfile>\n\n", ACTION_ADD);
	fprintf(stderr, "Compares <oldfile> and <newfile>, applying difference to <patchfile>.\n");
	fprintf(stderr, "\t-a\tAction to take when applying patch: %s, %s, %s, %s, %s\n",
			ACTION_COPY, ACTION_COPY_ONLY, ACTION_MOVE, ACTION_MOVE_ONLY, ACTION_ADD);
	fprintf(stderr, "\t\t\t%s - copies oldfile to newfile, applying diff\n", ACTION_COPY);
	fprintf(stderr, "\t\t\t%s - copies oldfile to newfile, no diff\n", ACTION_COPY_ONLY);
	fprintf(stderr, "\t\t\t%s - moves oldfile to newfile, applying diff\n", ACTION_MOVE);
	fprintf(stderr, "\t\t\t%s - moves oldfile to newfile, no diff\n", ACTION_MOVE_ONLY);
	fprintf(stderr, "\t\t\t%s - replaces oldfile, backing up to newfile (does not unapply)\n", ACTION_REPLACE);
	fprintf(stderr, "\t\t\t%s - adds newfile\n", ACTION_ADD);
	fprintf(stderr, "\t-od\tPath to location of old (or source) file\n");
	fprintf(stderr, "\t-o\tName of old (or source) file\n");
	fprintf(stderr, "\t-nd\tPath to location of new (or target) file\n");
	fprintf(stderr, "\t-n\tName of new (or target) file\n");
	fprintf(stderr, "\t-p\tName of patchfile\n");
	exit(HELPMSG);
}
