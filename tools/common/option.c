/* 
 * File:   option.c
 * Author: Michael C. Maggio
 *
 * Created on March 17, 2018, 8:05 PM
 */

#include	<stdio.h>				/* getchar, BUFSIZ */
#include	<stdlib.h>				/* atoi */
#include	<ctype.h>				/* toupper */
#include	<string.h>				/* strchr */

#include	"gendefs.h"
#include	"option.h"


int get_option()
{
	char input[BUFSIZ];					/* unedited input */
	int i;								/* loop counter */
	int option;							/* selected option */

	/* get input */
	for (i = 0; (input[i] = getchar()) != '\n'; i++);

	/* convert option to integer if numeric, otherwise grab first character */
	if (is_numeric(input, i))
		option = atoi(input);
	else
		option = toupper(input[0]);

	return option;
}

BOOL is_numeric(const char *input, int size)
{
	int i;								/* loop counter */

	for (i = 0; i < size; i++)
	{
		if (input[i] < 0x30 || input[i] > 0x39)
			return FALSE;
	}
	return TRUE;
}

int get_valid_option(const char *valid_chars)
{
	int option;

	do
	{
		option = get_option();
	}
	while (! strchr(valid_chars, option));

	return option;
}
