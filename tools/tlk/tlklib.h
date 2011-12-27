#ifndef	_TLKLIB_H
#define	_TLKLIB_H


#include	"File.h"


/* data structures */
struct u2tlk
{
	unsigned char *data;		/* tlk data */
	int size;					/* size of data */
	int *msgs;				/* array of messages */
	int num_msg;				/* number of messages */
};


/* TLK Data Function prototypes */
void decode_tlk_data(struct u2tlk tlk);
void encode_tlk_data(struct u2tlk tlk);
void build_msg_index(struct u2tlk *tlk);
int count_msgs(struct u2tlk tlk);

/* File Function Prototypes */
struct u2tlk load_tlk_data(File *tlkfile);
void save_tlk_data(File *tlkfile, struct u2tlk tlk);
void free_tlk(struct u2tlk *tlk);

/* IO Function Prototypes */
void print_tlk_msg(int msg, struct u2tlk tlk);
void print_all_tlk_msgs(struct u2tlk tlk);


#endif
