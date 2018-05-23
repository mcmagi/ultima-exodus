/* stringutil.c */

#include <stdio.h>		/* printf */
#include <malloc.h>		/* malloc, realloc, free */
#include <string.h>		/* strncpy, strcpy, strlen */
#include <ctype.h>		/* toupper */

#include "stringutil.h"

#define LIST_SIZE_INC	10

char * substring(const char *line, int start, int end)
{
	int len;
	char *str;

	len = end - start;

	/* reserve extra byte for null terminus */
	str = (char *) malloc((len+1) * sizeof(char));

	/* copy & return string */
	strncpy(str, &line[start], len);
	str[len] = '\0';
	return str;
}

char * substring_chomp(const char *line, int start, int end)
{
	/* advance start to first non-space character */
	while (line[start] == ' ')
		start++;

	/* rewind end to last non-space character */
	while (line[end-1] == ' ')
		end--;

	return substring(line, start, end);
}

int strpos(const char *line, char c)
{
	int i, len;

	len = strlen(line);
	for (i = 0; i < len; i++)
	{
		if (line[i] == c)
			return i;
	}

	return -1;
}

int strrpos(const char *line, char c)
{
	int i, len;

	len = strlen(line);
	for (i = len-1; i >= 0; i--)
	{
		if (line[i] == c)
			return i;
	}

	return -1;
}

StrList * split(const char *line)
{
	int startIdx = 0, endIdx = 0;
	StrList *list;
	int currentSize = 10;

	/* create strlist for return */
	list = malloc(sizeof(StrList));
	list->size = 0;
	list->entries = malloc(sizeof(char **) * currentSize);

	do
	{
		/* get end index */
		endIdx = strpos(&line[startIdx], ',');
		if (endIdx < 0)
			endIdx = strlen(&line[startIdx]);
		endIdx += startIdx;

		/* if not enough space for another entry, grow pointer array */
		if (list->size >= currentSize)
		{
			currentSize += LIST_SIZE_INC;
			list->entries = (char **) realloc(list->entries, sizeof(char **) * currentSize);
		}

		/* add entry */
		list->entries[list->size++] = substring(line, startIdx, endIdx);

		startIdx = endIdx + 1;
	}
	while (startIdx < strlen(line));

	/* right-size the list */
	if (list->size != currentSize)
		list->entries = (char **) realloc(list->entries, sizeof(char **) * list->size);

	return list;
}

void free_strlist(StrList *strlist)
{
	int i;

	if (strlist == NULL)
		return;

	for (i = 0; i < strlist->size; i++)
		free(strlist->entries[i]);
	free(strlist);
}

char * strclone(const char *str)
{
	int len;
	char *newstr;

	/* reserve space for new string */
	len = strlen(str);
	newstr = malloc(sizeof(char *) * (len+1));

	/* copy and return */
	strcpy(newstr, str);
	return newstr;
}

char * strtoupper(char *str)
{
	int len, i = 0;
	len = strlen(str);
	for (i = 0; i < len; i++)
		str[i] = toupper(str[i]);
	return str;
}
