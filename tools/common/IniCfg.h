/* 
 * File:   stringutil.h
 * Author: Michael C. Maggio
 */

#ifndef _INICFG_H
#define _INICFG_H

#include "gendefs.h"
#include "stringutil.h"
#include "File.h"

typedef struct
{
	char *key;
	char *value;
} IniCfgEntry;

typedef struct
{
	int size;
	IniCfgEntry **entries;
} IniCfg;

char * ini_get_value(const IniCfg *cfg, const char *key);
StrList * ini_get_value_list(const IniCfg *cfg, const char *key);
IniCfg * ini_load(File *f);
void ini_free(IniCfg *cfg);

#endif /* _INICFG_H */
