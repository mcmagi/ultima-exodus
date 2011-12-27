/* tlkio.c */


#include	<stdio.h>

#include	"tlklib.h"


/* prints all tlk messages in file */
void print_all_tlk_msgs(struct u2tlk tlk)
{
	int msg;							/* message number */


	/* loop through and print each message */
	for (msg = 0; msg < tlk.num_msg; msg++)
		print_tlk_msg(msg, tlk);
}

/* prints the specified tlk message */
void print_tlk_msg(int msg, struct u2tlk tlk)
{
	int idx;							/* index into file */


	if (msg >= 0 && msg < tlk.num_msg)
	{
		/* print header for message */
		printf("%4d - ", msg);

		/* print all chars to end of msg */
		for (idx = tlk.msgs[msg]; tlk.data[idx] != '\0' && idx < tlk.size;
		  idx++)
		{
			/* indent newlines */
			if (tlk.data[idx] == '\n')
				printf("\n       ");
			else
				printf("%c", tlk.data[idx]);
		}

		/* post newline at end */
		printf("\n");
	}
	else
		printf("msg number %d out of bounds!", msg);
}
