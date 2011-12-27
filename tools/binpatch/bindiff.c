/* bindiff.c */


#include	<stdio.h>				/* fprintf, printf */
#include	<stdlib.h>				/* exit */
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
	long filesize;					/* actual filesize */


	args = get_args(argc, argv);

	/* open patch file */
	patch = stat_file(args.patchfile);
	open_file(patch, APPEND_MODE);

	/* create or verify patch header */
	if (patch->buf.st_size == 0)
	{
		printf("New patch file - creating\n");
		write_patch_header(patch, sizeof(struct patch_header));

		/* seek to end of patch header */
		seek_through_file(patch, sizeof(struct patch_header), SEEK_SET);
	}
	else /* (patch->buf.st_size != 0) */
	{
		printf("Found existing file - verifying\n");
		verify_patch_header(patch);

		/* seek to end of file */
		seek_through_file(patch, patch->buf.st_size, SEEK_SET);
	}

	/* copies diff data from old/new files to patch file */
	diff(args.oldfile, args.newfile, patch, args.usenew);

	/* close patch file */
	close_file(patch);

	/* write patch header with updated size */
	patch = stat_file(args.patchfile);
	open_file(patch, READWRITE_MODE);
	write_patch_header(patch, patch->buf.st_size);
	close_file(patch);

	printf("file '%s', size %d\n", patch->filename, patch->buf.st_size);

	return SUCCESS;
}

/* fills PatchArgs structure */
PatchArgs get_args(int argc, char *argv[])
{
	PatchArgs args;
	int i;


	/* default to no */
	args.usenew = FALSE;

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-h") == MATCH)
			print_help_message();
		if (strcmp(argv[i], "-u") == MATCH)
			args.usenew = TRUE;
		else /* (i != argc) */
		{
			if (strcmp(argv[i], "-o") == MATCH)
				args.oldfile = argv[++i];
			else if (strcmp(argv[i], "-n") == MATCH)
				args.newfile = argv[++i];
			else if (strcmp(argv[i], "-p") == MATCH)
				args.patchfile = argv[++i];
			else
				print_help_message();
		}
	}

	if (args.oldfile == NULL || args.newfile == NULL || args.patchfile == NULL)
		print_help_message();

	return args;
}

void print_help_message()
{
	fprintf(stderr, "patchadd [-u] -o <oldfile> -n <newfile> -p <patchfile>\n\n");
	fprintf(stderr, "Compares <oldfile> and <newfile>, applying difference to <patchfile>.\n");
	fprintf(stderr, "\t-u\tUse new name when applying patch\n");
	fprintf(stderr, "\t-o\tName of old (or source) file\n");
	fprintf(stderr, "\t-n\tName of new (or target) file\n");
	fprintf(stderr, "\t-p\tName of patchfile\n\n");
	exit(HELPMSG);
}

void write_patch_header(File *patch, long size)
{
	struct patch_header pz;

	pz = build_patch_header(size);
	seek_through_file(patch, 0, SEEK_SET);
	write_to_file(patch, &pz, sizeof(struct patch_header));
}
