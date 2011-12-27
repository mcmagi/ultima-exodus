/* u3reset.c */


#include	"gendefs.h"
#include	"File.h"
#include	"FileUtil.h"
#include	"u3reset.h"


/* global vars */
BOOL debug;


int main(int argc, char *argv[])
{
	File *party;			/* party file */
	File *sosaria;			/* sosaria file */


	/* check for debug mode */
	if (argc == 2 && strcmp(argv[1], "-d") == MATCH)
		debug = TRUE;

	if (debug)
		printf("Opening file %s\n", PARTY);

	/* open player party file */
	party = stat_file(PARTY);
	open_file(party, APPEND_MODE);

	if (get_num_party_members(party) == 0)
	{
		if (debug)
			printf("Clearing contents of party file\n");

		/* clear the party file */
		clear_file(party);

		if (debug)
			printf("Opening file %s\n", SOSARIA);

		/* open sosaria map file */
		sosaria = stat_file(SOSARIA);
		open_file(sosaria, APPEND_MODE);

		/* remove transport and monsters from map */
		remove_transport(sosaria);
		remove_monsters(sosaria);

		/* reset moon and whirlpool */
		reset_moons(sosaria);
		reset_whirlpool(sosaria);

		/* close map file */
		close_file(sosaria);

		printf("Game map reset.  Start Ultima III and form a new party.\n");
	}
	else
		printf("You must disperse the party before resetting the game.\n");

	/* close party file */
	close_file(party);


	return SUCCESS;
}
