/* status.c */


#include	"cfg.h"		/* defs for cfg program */
#include	"gendefs.h"	/* general use defs */
#include	"File.h"		/* file handling */


/*
 * data handling functions
 */

int get_status(const unsigned char data[], int index)
{
	/* check if we are in our bounds */
	if (index < 0 || index > CFG_SZ - 1)
		printf("Index out of bounds\n");

	/* convert char into integer */
	return (int) data[index];
}

void get_status_str(const unsigned char data[], int index, char *str, int len)
{
	int i = 0;

	/* check if we are in our bounds */
	if (index < 0 || index+len > CFG_SZ)
		printf("Index out of bounds\n");

	for (i = 0; i < len; i++)
		str[i] = data[index+i];
}

BOOL get_status_bool(const unsigned char data[], int index)
{
	BOOL status;			/* status flag */


	/* check if we are in our bounds */
	if (index < 0 || index > CFG_SZ - 1)
		printf("Index out of bounds\n");

	/* convert char into boolean */
	if (get_status(data, index) == ON)
		status = TRUE;
	else
		status = FALSE;

	return status;
}

void set_status(unsigned char data[], int index, int status)
{
	/* check if we are in our bounds */
	if (index < 0 || index > CFG_SZ - 1)
		printf("Index out of bounds\n");

    data[index] = status;

	return;
}

void set_status_bool(unsigned char data[], int index, BOOL status)
{
    int int_status;

	/* check if we are in our bounds */
	if (index < 0 || index > CFG_SZ - 1)
		printf("Index out of bounds\n");

	/* convert char into boolean */
	if (status)
		int_status = ON;
	else
		int_status = OFF;

    set_status(data, index, int_status);

	return;
}

void set_status_str(unsigned char data[], int index, char *status, int len)
{
	int i = 0;

	/* check if we are in our bounds */
	if (index < 0 || index+len > CFG_SZ)
		printf("Index out of bounds\n");

	for (i = 0; i < len; i++)
    	data[index+i] = status[i];

	return;
}

void get_cfg_data(File *file, unsigned char *data)
{
    int size = CFG_SZ;


	/* postpone opening newfiles to avoid creating 0-byte files */

	if (! file->newfile)
	{
	    /* verify file size; we'll accept it if it's < CFG_SZ */
	    if (file->buf.st_size > CFG_SZ)
		    file_error(file, "Invalid file size");

		/* existing file -> first open it */
		open_file(file, READONLY_MODE);

        /* constrain size by file size */
        if (file->buf.st_size < CFG_SZ)
            size = file->buf.st_size;

		/* then read data */
		if (fread(data, size, 1, file->fp) != 1)
			file_error(file, "Could not read from file");
	}

	return;
}

void save_cfg_data(File *file, const unsigned char *data)
{
	if (file->newfile)
	{
		/* open the file */
		open_file(file, OVERWRITE_MODE);
		
		/* in future writes, it will no longer be a new file */
		file->newfile = FALSE;
	}
    else
    {
        reopen_file(file, OVERWRITE_MODE);
    }
	
	/* write data */
    write_to_file(file, data, CFG_SZ);

	return;
}
