/* IniCfg.c */

#include <stdio.h>		/* NULL */
#include <malloc.h>		/* malloc, free, realloc */
#include <string.h>		/* strlen, strncpy, strcmp */

#include "gendefs.h"
#include "stringutil.h"
#include "IniCfg.h"
#include "File.h"
#include "debug.h"

#define ENTRY_SIZE_INC		10


char * ini_get_value(const IniCfg *cfg, const char *key)
{
	int i;
	char *upperkey;

	upperkey = strtoupper(strclone(key));

	for (i = 0; i < cfg->size; i++)
	{
		if (strcmp(upperkey, cfg->entries[i]->key) == MATCH)
			return cfg->entries[i]->value;
	}

	free(upperkey);

	return NULL;
}

StrList * ini_get_value_list(const IniCfg *cfg, const char *key)
{
	const char *value;

	/* get increments value */
	value = ini_get_value(cfg, key);

	/* return increment as StrList */
	return value == NULL ? NULL : split(value);

}

IniCfg * ini_load(File *f)
{
	IniCfg *cfg;
	char *line;
	int i, linelen, valuestart;
	IniCfgEntry *entry;
	int entrysize = ENTRY_SIZE_INC;

	cfg = malloc(sizeof(IniCfg));
	cfg->size = 0;
	cfg->entries = (IniCfgEntry **) malloc(sizeof(IniCfgEntry *) * entrysize);

	do
	{
		/* loop initialization*/
		valuestart = 0;
		entry = NULL;

		/* read line */
		line = read_line_from_file(f);

		if (line != NULL)
		{
			linelen = strlen(line);
			for (i = 0; i < linelen; i++)
			{
				/* end at comments or EOL */
				if (line[i] == '#' || line[i] == ';' || line[i] == '\0')
				{
					break;
				}
				else if (line[i] == '=')
				{
					/* end of key found, create entry */
					entry = (IniCfgEntry *) malloc(sizeof(IniCfgEntry));
					entry->key = strtoupper(substring_chomp(line, 0, i));
					entry->value = NULL;

					/* next character beyond '=' starts value */
					valuestart=i+1;
				}
			}
		}

		if (entry != NULL)
		{
			/* if we found a key, extract the value */
			entry->value = substring_chomp(line, valuestart, i);

			if (DEBUG)
				printf("ini_load: adding entry: %s=%s\n", entry->key, entry->value);

			/* if not enough space for another entry, grow pointer array */
			if (cfg->size > entrysize)
			{
				entrysize += ENTRY_SIZE_INC;
				cfg->entries = (IniCfgEntry **) realloc(cfg->entries, sizeof(IniCfgEntry *) * entrysize);
			}

			/* add entry */
			cfg->entries[cfg->size++] = entry;
		}
	}
	while (line != NULL);

	/* resize pointer array to actual size */
	cfg->entries = (IniCfgEntry **) realloc(cfg->entries, sizeof(IniCfgEntry *) * cfg->size);

	return cfg;
}

void ini_free(IniCfg *cfg)
{
	int i = 0;

	if (cfg == NULL)
		return;

	/* free all entries */
	for (i = 0; i < cfg->size; i++)
	{
		free(cfg->entries[i]->key);
		free(cfg->entries[i]->value);
		free(cfg->entries[i]);
	}

	/* free entry array */
	free(cfg->entries);

	/* free struct */
	free(cfg);
}
