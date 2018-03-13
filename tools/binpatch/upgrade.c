/* 
 * File:   upgrade.c
 * Author: mcmaggio
 *
 * Created on May 6, 2017, 11:31 AM
 */

#include <stdio.h>			/* printf */
#include <stdlib.h>			/* exit, malloc, free */
#include <string.h>			/* strcmp */
#include <ctype.h>			/* toupper */

#include "File.h"
#include "DirList.h"
#include "gendefs.h"
#include "patch.h"
#include "patchapply.h"
#include "patchunapply.h"
#include "upgrade.h"


/*
 * 
 */
int main(int argc, char** argv)
{
	PatchData *data;			/* upgrade patch data */
	BOOL unapply = FALSE;		/* unapply mode flag */

	data = examine_patches(CURRENT_DIR);

	if (data->latest == NULL)
	{
		printf("No patch files were found. Aborting.\n");
		exit(EXIT_NO_PATCH_FILES);
	}

	if (data->applied != NULL)
	{
		/* check if latest/applied filenames match */
		if (strcmp(data->applied->filename, data->latest->filename) == MATCH)
		{
			printf("Latest patch %s is already applied.\n", data->applied->filename);
			unapply = TRUE;
		}
		else
		{
			printf("Removing patch %s and applying patch %s.\n", data->applied->filename, data->latest->filename);
		}
	}
	else
	{
		printf("Applying patch %s.\n", data->latest->filename);
	}

	/* get confirmation and & do the work */
	if (unapply)
	{
		printf("Unapply? (Y/N): ");
		if (get_yesno())
			do_downgrade(*data);
	}
	else
	{
		printf("Continue? (Y/N): ");
		if (get_yesno())
			do_upgrade(*data);
	}

	free_patchdata(data);

	return EXIT_SUCCESS;
}

PatchData *examine_patches(const char *path)
{
	File *dir;					/* directory file */
	DirList *dirList;			/* directory listing */
	File *patch = NULL;			/* patch file */
	PatchData *r;				/* result */
	int i;						/* counter */

	/* get list of patch files */
	dir = stat_file(path);
	dirList = list_dir(dir, "pat");
	close_file(dir);

	/* construct result struture */
	r = (PatchData*) malloc(sizeof(PatchData));
	r->latest = NULL;
	r->applied = NULL;
	r->dir = path;

	if (dirList->size > 0)
	{
		/* examine patch files */
		for (i = 0; i < dirList->size; i++)
		{
			patch = dirList->entries[i];
			open_file(patch, READONLY_MODE);

			printf("Found patch %s\n", patch->filename);
			verify_patch_header(patch);

			/* find latest patch version (depends on sort order) */
			if (r->latest == NULL || strcmp(patch->filename, r->latest->filename) > MATCH)
				r->latest = patch;

			/* find latest applied patch version */
			if ((r->applied == NULL || strcmp(patch->filename, r->applied->filename) > MATCH) && is_patch_applied(patch, path))
				r->applied = patch;
		}

		/* get new file instances before freeing dirlist */
		if (r->latest != NULL)
			r->latest = stat_file(r->latest->filename);
		if (r->applied != NULL)
			r->applied = stat_file(r->applied->filename);

		free_dirlist(dirList);
	}

	return r;
}

void free_patchdata(PatchData *data)
{
	/* close files */
	if (data->applied)
		close_file(data->applied);
	if (data->latest != data->applied)
		close_file(data->latest);

	free(data);
}

void do_upgrade(PatchData data)
{
	/* unapply currently applied patch */
	if (data.applied != NULL)
		do_downgrade(data);

	/* apply latest patch */
	open_file(data.latest, READONLY_MODE);
	verify_patch_header(data.latest);
	if (is_patch_unapplied(data.latest, data.dir))
	{
		seek_through_file(data.latest, sizeof(struct patch_header), SEEK_SET);
		apply_patch(data.latest, data.dir);
	}
	else
	{
		printf("Cannot apply patch! Missing or unexpected version of binaries found.");
		exit(EXIT_UNEXPECTED_VERSION);
	}
}

void do_downgrade(PatchData data)
{
	/* unapply currently applied patch */
	open_file(data.applied, READONLY_MODE);
	verify_patch_header(data.applied);
	unapply_patch(data.applied, data.dir);
}

char get_option(const char *validChars)
{
	char input[BUFSIZ];         /* unedited input */
	BOOL valid = FALSE;         /* input valid flag */
	int i = 0;

	do
	{
		/* get input */
		for (i = 0; (input[i] = toupper(getchar())) != '\n'; i++)
			valid = (strchr(validChars, input[i]) != NULL);
	}
	while (! valid);

	return input[0];
}

BOOL get_yesno()
{
	return get_option("YN") == 'Y';
}
