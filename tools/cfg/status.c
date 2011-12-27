/* status.c */


#include	"cfg.h"		/* defs for cfg program */
#include	"gendefs.h"	/* general use defs */
#include	"file.h"		/* file handling */


/*
 * data handling functions
 */

BOOL get_status(const unsigned char data[], int index)
{
	BOOL status;			/* status flag */


	/* check if we are in our bounds */
	if (index < 0 || index > CFG_SZ - 1)
		printf("Index out of bounds\n");

	/* convert char into boolean */
	if (data[index] == ON)
		status = TRUE;
	else
		status = FALSE;

	return status;
}

void set_status(unsigned char data[], int index, BOOL status)
{
	/* check if we are in our bounds */
	if (index < 0 || index > CFG_SZ - 1)
		printf("Index out of bounds\n");

	/* convert char into boolean */
	if (status)
		data[index] = ON;
	else
		data[index] = OFF;

	return;
}

void get_cfg_data(File *file, unsigned char *data, const unsigned char
	*defaults)
{
	int i;			/* loop counter */


	/* verify file size */
	if (! file->newfile && file->buf.st_size != CFG_SZ)
		file_error(file, "Invalid file size");

	/* check if this is a new file */
	if (file->newfile == TRUE)
	{
		/* new file -> set all 4 bytes */
		for (i = 0; i < CFG_SZ; i++)
			data[i] = defaults[i];
	

		/* postpone opening newfiles to avoid creating 0-byte files */
	}
	else
	{
		/* existing file -> first open it */
		open_file(file, READONLY_MODE);

		/* then read 4 bytes */
		if (fread(data, CFG_SZ, 1, file->fp) != 1)
			file_error(file, "Could not read from file");
	}

	return;
}

void save_cfg_data(File *file, const unsigned char *data)
{
	if (file->newfile)
	{
		/* open the file */
		open_file(file, READWRITE_MODE);
		
		/* in future writes, it will no longer be a new file */
		file->newfile = FALSE;
	}
	
	// seek to beginning of file
	if (fseek(file->fp, 0, SEEK_SET) != SUCCESS)
		file_error(file, "Could not seek through file");

	// write 4 bytes
	if (fwrite(data, CFG_SZ, 1, file->fp) != 1)
		file_error(file, "Could not write to file");

	return;
}
