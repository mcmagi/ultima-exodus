#ifndef	_U3_RESET
#define	_U3_RESET


#include	"File.h"


/* function prototypes */
int get_num_party_members(File *party);
void remove_transport(File *sosaria);
void remove_monsters(File *sosaria);
void reset_moons(File *sosaria);
void reset_whirlpool(File *sosaria);


/* standard dos 8.3 = 12 chars w/ dot */
#define	FILENAME_SZ		12


/* filenames */
#define	SOSARIA			"SOSARIA.ULT"
#define	PARTY			"PARTY.ULT"


#endif
