/* 
 * File:   upgrade.c
 * Author: mcmaggio
 *
 * Created on May 6, 2017, 11:31 AM
 */

#include <stdio.h>			/* printf, NULL, BUFSIZ */
#include <stdlib.h>			/* exit, malloc, free */
#include <string.h>			/* strcmp, strncmp, strlen, strcpy, strcat */
#include <ctype.h>			/* toupper */

#include "File.h"
#include "DirList.h"
#include "IniCfg.h"
#include "option.h"
#include "gendefs.h"
#include "filepath.h"
#include "stringutil.h"
#include "patch.h"
#include "patchapply.h"
#include "patchunapply.h"
#include "upgrade.h"
#include "debug.h"


/*
 * 
 */
int main(int argc, const char ** argv)
{
	PatchData *data;			/* upgrade patch data */
	BOOL unapply = FALSE;		/* unapply mode flag */
	IniCfg *iniCfg = NULL;		/* upgrade ini cfg data */

	UpgradeArgs args = parse_args(argc, argv);
	DEBUG = args.debug;

	/* load ini file */
	iniCfg = load_upgrade_ini(args.upgrade_type);

	data = create_patchdata(CURRENT_DIR);

	/* get latest & applied upgrade patches */
	examine_upgrade_patches(data, args.upgrade_type);

	if (data->latest == NULL)
	{
		printf("No patch %s files were found. Aborting.\n", args.upgrade_type);
		exit(EXIT_NO_PATCH_FILES);
	}

	/* if no upgrade patches applied, check release patches */
	if (! data->has_upgrade && iniCfg != NULL)
		examine_release_patches(data, iniCfg);

	/* Print game versions */
	printf("  Current Game Version:  %s\n", get_patch_version(iniCfg, data->applied));
	printf("Latest Upgrade Version:  %s\n\n", get_patch_version(iniCfg, data->latest));

	/* check if latest/applied filenames match, switch to unapply mode */
	unapply = data->applied != NULL && strcmp(data->applied->filename, data->latest->filename) == MATCH;

	/* get confirmation & do the work */
	if (unapply)
	{
		printf("Latest patch is already applied.\n");
		printf("Unapply? (Y/N): ");
		if (args.yes || get_yesno())
			do_downgrade(iniCfg, data);
	}
	else
	{
		printf("Upgrading to latest version.\n");
		printf("Continue? (Y/N): ");
		if (args.yes || get_yesno())
			do_upgrade(iniCfg, data);
	}

	free_patchdata(data);
	ini_free(iniCfg);
	free(args.upgrade_type);

	return EXIT_SUCCESS;
}

void examine_upgrade_patches(PatchData *r, const char *upgrade_type)
{
	File *dir;					/* directory file */
	DirList *dirList;			/* directory listing */
	File *patch = NULL;			/* patch file */
	int i;						/* counter */

	/* get list of patch files */
	dir = stat_file(r->dir);
	dirList = list_dir(dir, "pat");
	close_file(dir);

	/* examine patch files in reverse listing order (usually alpha sorted) */
	for (i = dirList->size - 1; i >= 0; i--)
	{
		patch = dirList->entries[i];

		/* only look at files that begin with specified upgrade type */
		if (strncmp(patch->filename, upgrade_type, strlen(upgrade_type)) != MATCH)
			continue;

		open_file(patch, READONLY_MODE);

		if (DEBUG)
			printf("Found patch %s\n", patch->filename);
		verify_patch_header(patch);

		/* find latest patch version (depends on version in filename) */
		if (r->latest == NULL || strcmp(patch->filename, r->latest->filename) > MATCH)
			r->latest = patch;

		/* find latest applied patch version */
		if ((r->applied == NULL || strcmp(patch->filename, r->applied->filename) > MATCH) && is_patch_applied(patch, r->dir, FALSE))
			r->applied = patch;
	}

	/* get new file instances before freeing dirlist */
	if (r->latest != NULL)
		r->latest = stat_file(r->latest->filename);
	if (r->applied != NULL)
		r->applied = stat_file(r->applied->filename);

	/* indicate that applied patch is an upgrade (as opposed to a release) */
	if (r->applied != NULL)
		r->has_upgrade = TRUE;

	free_dirlist(dirList);
}

void examine_release_patches(PatchData *r, const IniCfg *iniCfg)
{
	StrList *releases;		/* release patch filenames */
	const char *base;			/* minimum base patch filename needed for upgrades */
	File *patch = NULL;			/* patch file */
	int i, j;					/* counter */
	int appliedLevel = -1;
	int baseLevel = -1;

	releases = ini_get_value_list(iniCfg, INI_KEY_RELEASES);
	base = ini_get_value(iniCfg, INI_KEY_BASE);

	/* examine patch files */
	for (i = releases->size - 1; i >= 0; i--)
	{
		patch = stat_file(releases->entries[i]);
		open_file(patch, READONLY_MODE);

		if (DEBUG)
			printf("Found patch %s\n", patch->filename);
		verify_patch_header(patch);

		/* find latest applied release patch version */
		if (r->applied == NULL && is_patch_applied(patch, r->dir, FALSE))
		{
			r->applied = patch;
			appliedLevel = i;
		}

		if (strcmp(patch->filename, base) == MATCH)
			baseLevel = i;
	}

	if (appliedLevel < baseLevel)
	{
		/* we are under base level needed for upgrade patch */
		r->num_below = baseLevel - appliedLevel;
		r->below = malloc(sizeof(File**) * r->num_below);
		for (i = appliedLevel+1, j = 0; i <= baseLevel; i++)
		{
			if (DEBUG)
				printf("Under-applied release patch: %s\n", releases->entries[i]);
			r->below[j++] = stat_file(releases->entries[i]);
		}
	}
	else if (appliedLevel > baseLevel)
	{
		/* we are over base level needed for upgrade patch and need to rollback */
		r->num_above = appliedLevel - baseLevel;
		r->above = malloc(sizeof(File**) * r->num_above);
		for (i = baseLevel+1, j = 0; i <= appliedLevel; i++)
		{
			if (DEBUG)
				printf("Over-applied release patch: %s\n", releases->entries[i]);
			r->above[j++] = stat_file(releases->entries[i]);
		}
	}

	/* get new file instances before freeing strlist */
	if (r->applied != NULL)
		r->applied = stat_file(r->applied->filename);

	free_strlist(releases);
}

PatchData *create_patchdata(const char *path)
{
	PatchData *r = NULL;

	/* construct result structure */
	r = (PatchData*) malloc(sizeof(PatchData));
	r->has_upgrade = FALSE;
	r->applied = NULL;
	r->latest = NULL;
	r->below = NULL;
	r->num_below = 0;
	r->above = NULL;
	r->num_above = 0;
	r->dir = path;

	return r;
}

void free_patchdata(PatchData *data)
{
	int i = 0;

	/* close files */
	if (data->applied)
		close_file(data->applied);
	if (data->latest != data->applied)
		close_file(data->latest);
	if (data->below)
	{
		for (i = 0; i < data->num_below; i++)
			close_file(data->below[i]);
		free(data->below);
	}
	if (data->above)
	{
		for (i = 0; i < data->num_above; i++)
			close_file(data->above[i]);
		free(data->above);
	}

	free(data);
}

void do_upgrade(IniCfg *iniCfg, PatchData *data)
{
	int i;

	if (data->has_upgrade)
	{
		/* unapply currently applied patch */
		downgrade_patch(iniCfg, data->applied, data->dir);

		/* determine release version after rolling back upgrade patch */
		data->applied = NULL;
		examine_release_patches(data, iniCfg);
	}

	if (data->num_below > 0)
	{
		/* apply any release patches below base */
		for (i = 0; i < data->num_below; i++)
			upgrade_patch(iniCfg, data->below[i], data->dir);
	}
	else if (data->num_above > 0)
	{
		/* unapply any release patches above base */
		for (i = 0; i < data->num_above; i++)
			downgrade_patch(iniCfg, data->above[i], data->dir);
	}

	/* apply latest patch */
	upgrade_patch(iniCfg, data->latest, data->dir);
}

void do_downgrade(IniCfg *iniCfg, PatchData *data)
{
	/* unapply currently applied patch */
	downgrade_patch(iniCfg, data->applied, data->dir);
}

void upgrade_patch(IniCfg *iniCfg, File *patch, const char *dir)
{
	printf("Applying patch: %s\n", get_patch_version(iniCfg, patch));
	open_file(patch, READONLY_MODE);
	verify_patch_header(patch);
	if (is_patch_unapplied(patch, dir, TRUE))
	{
		seek_through_file(patch, sizeof(struct patch_header), SEEK_SET);
		apply_patch(patch, dir);
		close_file(patch);
	}
	else
	{
		printf("Cannot apply patch! Missing or unexpected version of binaries found.");
		exit(EXIT_UNEXPECTED_VERSION);
	}
}

void downgrade_patch(IniCfg *iniCfg, File *patch, const char *dir)
{
	printf("Unapplying patch: %s\n", get_patch_version(iniCfg, patch));
	open_file(patch, READONLY_MODE);
	verify_patch_header(patch);
	unapply_patch(patch, dir);
	close_file(patch);
}

BOOL get_yesno()
{
	return get_valid_option("YN") == 'Y';
}

IniCfg * load_upgrade_ini(const char *upgrade_type)
{
	File *iniFile = NULL;		/* upgrade ini file */
	IniCfg *iniCfg = NULL;		/* upgrade ini cfg data */
	char filename[BUFSIZ];		/* filename buffer */

	strcpy(filename, upgrade_type);
	strcat(filename, ".ini");

	/* load ini file */
	iniFile = stat_file(filename);
	if (! iniFile->newfile)
	{
		if (DEBUG) printf("loading inifile: %s\n", filename);
		open_file(iniFile, READONLY_MODE);
		iniCfg = ini_load(iniFile);
	}
	close_file(iniFile);

	return iniCfg;
}

char * get_patch_version(const IniCfg *iniCfg, const File *patch)
{
	char *iniKey = INI_KEY_NONE;
	char *versionStr = NULL;
	
	if (patch != NULL)
		iniKey = patch->filename;

	if (iniCfg != NULL)
		versionStr = ini_get_value(iniCfg, iniKey);

	return versionStr == NULL ? iniKey : versionStr;
}

UpgradeArgs parse_args(int argc, const char **argv)
{
	UpgradeArgs args;
	FileParts *fp;
	int i;

	/* initialize struct */
	args.upgrade_type = NULL;
	args.yes = FALSE;
	args.debug = FALSE;

	/* This is a bit hacky, but we determine the upgrade type from the first four
	 * characters of the upgrade tool called.  So if we're invoked as './u2upw' then we
	 * expect to find upgrades of type 'u2up'.
	 */
	fp = split_filename(argv[0]);
	args.upgrade_type = substring(fp->name, 0, 4);

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-h") == MATCH)
			print_help_message(fp->name);
		if (strcmp(argv[i], "-v") == MATCH)
			args.debug = TRUE;
		else if (strcmp(argv[i], "-y") == MATCH)
			args.yes = TRUE;
	}

	free(fp);

	return args;
}

void print_help_message(const char *name)
{
	fprintf(stderr, "%s [-v] [-y]\n", name);
	fprintf(stderr, "Determines an upgrade plan and applies patches to the current directory.\n");
	fprintf(stderr, "\t-v\tVerbose (debug)\n");
	fprintf(stderr, "\t-y\tAutomatically say 'yes'\n");
	exit(HELPMSG);
}
