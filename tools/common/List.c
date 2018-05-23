/* List.c */

#include <stdio.h>			/* NULL */
#include <malloc.h>			/* malloc, realloc, free */
#include "List.h"

List * list_create()
{
	List *list;

	/* create list and initialize properties */
	list = (List *) malloc(sizeof(List));
	list->size = 0;
	list->memsize = LIST_GROWTH;
	list->entries = malloc(sizeof(void *) * list->memsize);

	return list;
}

void list_free(List *list)
{
	int i;

	if (list == NULL)
		return;

	for (i = 0; i < list->size; i++)
		free(list->entries[i]);
	free(list->entries);
	free(list);
}

void list_add(List *list, void *value)
{
	if (list->size >= list->memsize)
	{
		/* grow the list */
		list->memsize += LIST_GROWTH;
		list->entries = realloc(list->entries, sizeof(void *) * list->memsize);
	}

	/* append value to end of list */
	list->entries[list->size++] = value;
}
