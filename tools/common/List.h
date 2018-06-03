/* 
 * File:   List.h
 * Author: Michael C. Maggio
 */

#ifndef _LIST_H
#define _LIST_H

#define LIST_GROWTH		10

/* general-purpose list */
typedef struct
{
	int size;
	void **entries;	
	int memsize;
} List;

List * list_create();
void list_free(List *list);
void list_add(List *list, void *value);


#endif /* _LIST_H */
