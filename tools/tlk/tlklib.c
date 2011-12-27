/* u2tlk.c */


#include	<malloc.h>

#include	"tlklib.h"


/* decodes tlk data */
void decode_tlk_data(struct u2tlk tlk)
{
	int idx;							/* index into file */


	/* loop through all tlk data */
	for (idx = 0; idx < tlk.size; idx++)
	{
		/* as long as char is not a null */
		if (tlk.data[idx] != '\0')
			/* clear bit 8 */
			tlk.data[idx] &= 0x7F;

		/* replace <cr>'s with newlines */
		if (tlk.data[idx] == '\r')
			tlk.data[idx] = '\n';
	}
}

/* encodes tlk data */
void encode_tlk_data(struct u2tlk tlk)
{
	int idx;							/* index into file */


	/* loop through all tlk data */
	for (idx = 0; idx < tlk.size; idx++)
	{
		/* replace newlines with <cr>'s */
		if (tlk.data[idx] == '\n')
			tlk.data[idx] = '\r';

		/* as long as char is not a null */
		if (tlk.data[idx] != '\0')
			/* set bit 8 */
			tlk.data[idx] |= 0x80;
	}
}

/* build an index of each message in tlk data */
void build_msg_index(struct u2tlk *tlk)
{
	int idx;							/* index into file */
	int msg;							/* message number */


	/* allocate memory for messages */
	tlk->num_msg = count_msgs(*tlk);
	tlk->msgs = (int *) malloc(sizeof(int) * tlk->num_msg);

	/* move to beginning of first message */
	for (idx = 0; tlk->data[idx] == 0 && idx < tlk->size; idx++);

	/* loop through each message */
	for (msg = 0; idx < tlk->size; msg++)
	{
		/* get index of message */
		tlk->msgs[msg] = idx;

		/* move through all chars to end of msg */
		for ( ; tlk->data[idx] != '\0' && idx < tlk->size; idx++);

		/* move to beginning of next message */
		for ( ; tlk->data[idx] == '\0' && idx < tlk->size; idx++);
	}
}

/* returns count of # of msgs in tlk data */
int count_msgs(struct u2tlk tlk)
{
	int idx;							/* index into file */
	int msg;							/* message number */


	/* move to beginning of first message */
	for (idx = 0; tlk.data[idx] == 0 && idx < tlk.size; idx++);

	/* count each message */
	for (msg = 0; idx < tlk.size; msg++)
	{
		/* move to end of text */
		for ( ; tlk.data[idx] != '\0' && idx < tlk.size; idx++);

		/* move to beginning of next message */
		for ( ; tlk.data[idx] == '\0' && idx < tlk.size; idx++);
	}

	return msg;
}
