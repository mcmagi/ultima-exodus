/* u5patch.h */

#ifndef _U5PATCH
#define _U5PATCH

#include	"gendefs.h"
#include	"File.h"


void patch(File *f, const long offset, const long size, const char *name, const
	char *game, const unsigned char *olddata, const unsigned char *newdata);


#define DATA_FILE		"data.ovl"


/* data sizes */

#define MID_SZ		8
#define VGA_SZ		8


/* old and new data for U5 DATA.OVL */

const unsigned char mid_olddata[MID_SZ] = "T1K.DRV";
const unsigned char vga_olddata[VGA_SZ] = "HER.DRV";

const unsigned char mid_newdata[MID_SZ] = "MID.DRV";
const unsigned char vga_newdata[VGA_SZ] = "VGA.DRV";


/* offsets */

const long mid_offset = 0x5350;
const long vga_offset = 0x5358;


#endif
