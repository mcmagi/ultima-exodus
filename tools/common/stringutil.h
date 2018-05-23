/* 
 * File:   stringutil.h
 * Author: Michael C. Maggio
 */

#ifndef _STRINGUTIL_H
#define _STRINGUTIL_H

typedef struct {
	char size;
	char **entries;
} StrList;

char * substring(const char *line, int start, int end);
char * substring_chomp(const char *line, int start, int end);
int strpos(const char *line, char c);
int strrpos(const char *line, char c);
StrList * split(const char *line);
void free_strlist(StrList *strlist);
char * strclone(const char *str);
char * strtoupper(char *str);

#endif /* _STRINGUTIL_H */

