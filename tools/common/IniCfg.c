/* IniCfg.c */

#include <stdio.h>		/* NULL */
#include <malloc.h>		/* malloc, free, realloc */
#include <string.h>		/* strlen, strncpy, strcmp */

#include "gendefs.h"
#include "IniCfg.h"
#include "File.h"

#define ENTRY_SIZE_INC		10


/* local (non-exported) prototypes */
char * ini_load_string(const char *line, int start, int end);


char * ini_get_value(const IniCfg *cfg, const char *key)
{
	int i;

	for (i = 0; i < cfg->size; i++)
	{
		if (strcmp(key, cfg->entries[i]->key) == MATCH)
			return cfg->entries[i]->value;
	}
	return NULL;
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
	cfg->entries = (IniCfgEntry **) malloc(sizeof(IniCfgEntry **) * entrysize);

	do
	{
		line = read_line_from_file(f);

		if (line != NULL)
		{
			linelen = strlen(line);
			for (i = 0; i < linelen; i++)
			{
				/* end at comments or EOL */
				if (line[i] == '#' || line[i] == ';' || line[i] == '\0')
				{
					/* if we found a key, extract the value before breaking */
					if (entry != NULL)
						entry->value = ini_load_string(line, valuestart, i);

					break;
				}
				else if (line[i] == '=')
				{
					/* end of key found, create entry */
					entry = (IniCfgEntry *) malloc(sizeof(IniCfgEntry));
					entry->key = ini_load_string(line, 0, i);
					entry->value = NULL;

					/* next character beyond '=' starts value */
					valuestart=i+1;
				}
			}
		}

		if (entry != NULL)
		{
			/* if not enough space for another entry, grow pointer array */
			if (cfg->size > entrysize)
			{
				entrysize += ENTRY_SIZE_INC;
				cfg->entries = (IniCfgEntry **) realloc(cfg->entries, sizeof(IniCfgEntry **) * entrysize);
			}

			/* add entry */
			cfg->entries[cfg->size] = entry;
			cfg->size++;
		}
	}
	while (line != NULL);

	/* resize pointer array to actual size */
	cfg->entries = (IniCfgEntry **) realloc(cfg->entries, sizeof(IniCfgEntry **) * cfg->size);

	return cfg;
}

char * ini_load_string(const char *line, int start, int end)
{
	int len;
	char *str;

	/* advance start to first non-space character */
	while (line[start] == ' ')
		start++;

	/* rewind end to last non-space character */
	while (line[end-1] == ' ')
		end--;

	/* end of key found */
	len = end-start;

	/* reserve extra byte for null terminus */
	str = (char *) malloc((len+1) * sizeof(char));

	/* copy & return string */
	strncpy(str, &line[start], len);
	str[len] = '\0';
	return str;
}

void ini_free(IniCfg *cfg)
{
	int i = 0;

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
