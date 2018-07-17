/* 
 * File:   upgrade.c
 * Author: mcmaggio
 *
 * Created on May 6, 2017, 11:31 AM
 */

#include <stdio.h>			/* printf, NULL, BUFSIZ */
#include <stdlib.h>			/* exit, malloc, free, system */
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
	BOOL applyable = TRUE;		/* flag to indicate first patch is applyable */
	BOOL unapply = FALSE;		/* unapply mode flag */
	IniCfg *iniCfg = NULL;		/* upgrade ini cfg data */
	char *readme;				/* readme filename */

	UpgradeArgs args = parse_args(argc, argv);
	DEBUG = args.debug;

	/* load ini file */
	iniCfg = load_upgrade_ini(args.upgrade_type);

	readme = ini_get_value(iniCfg, INI_KEY_README);
	if (! args.yes && readme != NULL)
		print_readme(readme);

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

	/* check if we have a rollback patch */
	examine_rollback_patches(data, iniCfg);

	/* if no release or rollback patches applied, check if we can apply the first one */
	if (data->applied == NULL)
		applyable = can_patch_be_applied(data);

	/* Print game versions */
	printf("  Current Game Version:  %s\n", applyable ? get_patch_version(iniCfg, data->applied) : "(unknown version)");
	printf("Latest Upgrade Version:  %s\n\n", get_patch_version(iniCfg, data->latest));

	/* check if latest/applied filenames match, switch to unapply mode */
	unapply = data->applied != NULL && strcmp(data->applied->filename, data->latest->filename) == MATCH;

	/* get confirmation & do the work */
	if (! applyable)
	{
		printf("Upgrade aborted! -- Game version could not be identified.\n");
		printf("Please contact The Exodus Project for support.\n");
		press_enter();
	}
	else if (unapply)
	{
		printf("Latest patch is already applied.\n");
		printf("Unapply? (Y/N): %s", args.yes ? "Y\n" : "");
		if (args.yes || get_yesno())
		{
			do_downgrade(iniCfg, data);
			if (! args.yes)
				press_enter();
		}
	}
	else
	{
		printf("Upgrading to latest version.\n");
		printf("Continue? (Y/N): %s", args.yes ? "Y\n" : "");
		if (args.yes || get_yesno())
		{
			do_upgrade(iniCfg, data);
			if (! args.yes)
			{
				press_enter();
				invoke_config(iniCfg);
			}
		}
	}

	free_patchdata(data);
	free(readme);
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

	/* examine patch files in reverse order */
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
			r->applied = stat_file(patch->filename);
			appliedLevel = i;
		}

		if (strcmp(patch->filename, base) == MATCH)
			baseLevel = i;

		close_file(patch);
	}

	if (r->below != NULL)
		list_free(r->below);
	r->below = list_create();
	if (r->above != NULL)
		list_free(r->above);
	r->above = list_create();

	if (appliedLevel < baseLevel)
	{
		/* we are under base level needed for upgrade patch */
		for (i = appliedLevel+1, j = 0; i <= baseLevel; i++)
		{
			if (DEBUG)
				printf("Under-applied release patch: %s\n", releases->entries[i]);
			list_add(r->below, stat_file(releases->entries[i]));
		}
	}
	else if (appliedLevel > baseLevel)
	{
		/* we are over base level needed for upgrade patch and need to rollback */
		for (i = baseLevel+1, j = 0; i <= appliedLevel; i++)
		{
			if (DEBUG)
				printf("Over-applied release patch: %s\n", releases->entries[i]);
			list_add(r->above, stat_file(releases->entries[i]));
		}
	}

	free_strlist(releases);
}

void examine_rollback_patches(PatchData *r, const IniCfg *iniCfg)
{
	int prefix_len;				/* ini key prefix length */
	char ini_key[32];			/* rollback ini key */
	char *rollback;				/* rollback patch filenames (reference) */
	File *patch = NULL;			/* patch file (owned) */

	// build ini key
	prefix_len = strlen(INI_KEY_ROLLBACK);
	strcpy(ini_key, INI_KEY_ROLLBACK);
	if (r->applied != NULL)
		strcpy(&ini_key[prefix_len], r->applied->filename);
	else
		strcpy(&ini_key[prefix_len], INI_KEY_NONE);

	rollback = ini_get_value(iniCfg, ini_key);

	if (rollback == NULL)
		return;

	/* examine patch file */
	patch = stat_file(rollback);
	open_file(patch, READONLY_MODE);

	if (DEBUG)
		printf("Found patch %s\n", patch->filename);
	verify_patch_header(patch);

	/* if rollback patch is applied, set it a latest applied */
	if (is_patch_applied(patch, r->dir, FALSE))
	{
		close_file(r->applied);
		r->applied = patch;
		r->has_upgrade = TRUE;
		if (DEBUG)
			printf("Patch to rollback: %s\n", rollback);
	}
	else
	{
		close_file(patch);
	}
}

BOOL can_patch_be_applied(PatchData *r)
{
	File *firstPatch = NULL;
	BOOL applyable = TRUE;

	/* determine first patch to apply */
	if (r->below->size > 0)
	{
		/* if has unapplied release patches, check first one */
		firstPatch = (File *) r->below->entries[0];
	}
	else if (r->above->size == 0)
	{
		/* if we're not rolling back a release patch (which is already validated to work),
		 * check the upgrade patch */
		firstPatch = r->latest;
	}

	if (firstPatch != NULL)
	{
		firstPatch = stat_file(firstPatch->filename);
		open_file(firstPatch, READONLY_MODE);
		verify_patch_header(firstPatch);

		applyable = is_patch_unapplied(firstPatch, r->dir, FALSE);

		close_file(firstPatch);
	}

	return applyable;
}

PatchData *create_patchdata(const char *path)
{
	PatchData *r = NULL;			/* result structure */

	/* construct result structure */
	r = (PatchData*) malloc(sizeof(PatchData));
	r->has_upgrade = FALSE;
	r->applied = NULL;
	r->latest = NULL;
	r->below = list_create();
	r->above = list_create();
	r->dir = path;

	return r;
}

void free_patchdata(PatchData *data)
{
	int i = 0;				/* loop counter */

	/* close files */
	if (data->applied != NULL)
		close_file(data->applied);

	if (data->latest != NULL && data->latest != data->applied)
		close_file(data->latest);

	list_free(data->below);
	list_free(data->above);

	free(data);
}

void do_upgrade(IniCfg *iniCfg, PatchData *data)
{
	int i;			/* loop counter */

	if (data->has_upgrade)
	{
		/* unapply currently applied patch */
		downgrade_patch(iniCfg, data->applied, data->dir);

		/* determine release version after rolling back upgrade patch */
		close_file(data->applied);
		data->applied = NULL;
		examine_release_patches(data, iniCfg);
	}

	if (data->below->size > 0)
	{
		/* apply any release patches below base */
		for (i = 0; i < data->below->size; i++)
			upgrade_patch(iniCfg, (File *) data->below->entries[i], data->dir);
	}
	else if (data->above->size > 0)
	{
		/* unapply any release patches above base */
		for (i = 0; i < data->above->size; i++)
			downgrade_patch(iniCfg, (File *) data->above->entries[i], data->dir);
	}

	/* apply latest patch */
	upgrade_patch(iniCfg, data->latest, data->dir);
	printf("Upgrade complete!\n");
}

void do_downgrade(IniCfg *iniCfg, PatchData *data)
{
	/* unapply currently applied patch */
	downgrade_patch(iniCfg, data->applied, data->dir);
	printf("Removal complete!\n");
}

void upgrade_patch(IniCfg *iniCfg, File *patch, const char *dir)
{
	printf("\nApplying patch: %s\n", get_patch_version(iniCfg, patch));
	open_file(patch, READONLY_MODE);
	verify_patch_header(patch);
	if (is_patch_unapplied(patch, dir, TRUE))
	{
		seek_through_file(patch, sizeof(struct patch_header), SEEK_SET);
		apply_patch(patch, dir);
	}
	else
	{
		printf("Cannot apply patch! Missing or unexpected version of binaries found.\n");
		printf("You will need to reinstall the game before re-applying the patch.\n");
		press_enter();
		exit(EXIT_UNEXPECTED_VERSION);
	}
}

void downgrade_patch(IniCfg *iniCfg, File *patch, const char *dir)
{
	printf("\nUnapplying patch: %s\n", get_patch_version(iniCfg, patch));
	open_file(patch, READONLY_MODE);
	verify_patch_header(patch);
	unapply_patch(patch, dir);
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
	char *iniKey = INI_KEY_NONE;			/* key to ini cfg option */
	char *versionStr = NULL;				/* derived patch version string */
	
	if (patch != NULL)
		iniKey = patch->filename;

	if (iniCfg != NULL)
		versionStr = ini_get_value(iniCfg, iniKey);

	/* if can't find version string, default to iniKey value */
	return versionStr == NULL ? iniKey : versionStr;
}

void print_readme(char *filename)
{
	File *file = NULL;		/* readme file */
	char *line = NULL;		/* line buffer area */
	int i = 0;				/* loop counter */

	if (DEBUG)
		printf("searching for readme file: %s\n", filename);
	file = stat_file(filename);
	if (! file->newfile)
	{
		open_file(file, READONLY_MODE);
		for (i = 0; ! end_of_file(file); i++)
		{
			line = read_line_from_file(file);

			/* pause on page break */
			if (strcmp(line, README_PAGE_BREAK) == MATCH)
				press_enter();

			printf("%s\n", line);
			free(line);
		}
	}
	close_file(file);
}

void press_enter()
{
	printf("(Press ENTER to continue)");
	get_option();
}

void invoke_config(IniCfg *iniCfg)
{
	char config_key[20];
	char *config;

	sprintf(config_key, "%s.%s", INI_KEY_CONFIG, TARGET);
	config = ini_get_value(iniCfg, config_key);
	if (config != NULL)
		system(config);
}

UpgradeArgs parse_args(int argc, const char **argv)
{
	UpgradeArgs args;		/* arguments strcture */
	FileParts *fp;			/* parts of current filename */
	int i;					/* loop counter */

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
	fprintf(stderr, "\t-y\tAutomatically say 'yes' (scripted install)\n");
	exit(HELPMSG);
}
