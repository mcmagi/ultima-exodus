/* u2patch.h */

#ifndef _U2PATCH
#define _U2PATCH


#define U2_EXE			"ultimaii.exe"
#define PANGEA_MAP		"mapx10"
#define PANGEA_DNG		"mapx15"


/* data sizes */

#define GMAP_SZ		80
#define OVERFLOW_SZ		7
#define PICCAS_SZ		2
#define FILEIO_SZ		164
#define DUNGEON_SZ		260
#define PANGEA_SZ		1


/* old and new data for Galactic Maps */

const unsigned char gmap_olddata[GMAP_SZ] =
{
	0xe8, 0x52, 0xf9, 0xbb, 0x14, 0x00, 0xe8, 0x20,
	0x95, 0xeb, 0x06, 0xdd, 0x3d, 0x1b, 0xff, 0x75,
	0xef, 0xb0, 0x00, 0xa2, 0x4a, 0x00, 0xb0, 0x04,
	0xa2, 0x49, 0x00, 0xe8, 0x83, 0x00, 0xc3, 0xeb,
	0x19, 0xdd, 0x28, 0x49, 0x4e, 0x53, 0x45, 0x52,
	0x54, 0x20, 0x47, 0x41, 0x4c, 0x41, 0x43, 0x54,
	0x49, 0x43, 0x20, 0x44, 0x49, 0x53, 0x4b, 0x29,
	0x8d, 0x00, 0xe8, 0x18, 0xf9, 0xbb, 0x14, 0x00,
	0xe8, 0xe6, 0x94, 0xeb, 0x06, 0xdd, 0x3d, 0x1b,
	0xff, 0x75, 0xef, 0xb0, 0x00, 0xa2, 0x4a, 0x00
};

const unsigned char gmap_newdata[GMAP_SZ] =
{
	0xe8, 0x52, 0xf9, 0xbb, 0x14, 0x00, 0xe8, 0x20,
	0x95, 0xb0, 0x58, 0xe8, 0x15, 0x00, 0x90, 0x90,
	0x90, 0xb0, 0x00, 0xa2, 0x4a, 0x00, 0xb0, 0x04,
	0xa2, 0x49, 0x00, 0xe8, 0x83, 0x00, 0xc3, 0xeb,
	0x19, 0xdd, 0x28, 0x2e, 0xa2, 0xba, 0x22, 0x2e,
	0xa2, 0xcc, 0x22, 0x2e, 0xa2, 0xf7, 0x22, 0xc3,
	0x00, 0x2d, 0x55, 0x44, 0x49, 0x43, 0x2d, 0x29,
	0x8d, 0x00, 0xe8, 0x18, 0xf9, 0xbb, 0x14, 0x00,
	0xe8, 0xe6, 0x94, 0xb0, 0x47, 0xe8, 0xdb, 0xff,
	0x90, 0x90, 0x90, 0xb0, 0x00, 0xa2, 0x4a, 0x00
};


/* old and new data for divide overflow fix */

const unsigned char overflow_olddata[OVERFLOW_SZ] =
	{ 0xb4, 0x00, 0xcd, 0x1a, 0x89, 0x0e, 0x52 };

const unsigned char overflow_newdata[OVERFLOW_SZ] =
	{ 0xc7, 0x06, 0x74, 0x00, 0xff, 0x00, 0xc3 };


/* old and new data for PICCAS image */

const unsigned char piccas_olddata[PICCAS_SZ] = { 0xeb, 0x71 };

const unsigned char piccas_newdata[PICCAS_SZ] = { 0x90, 0x90 };


/* old data for File IO patch */

const unsigned char fileio_olddata[FILEIO_SZ] =
{
	0x2e, 0x88, 0x26,
	0x04, 0x4f, 0x2e, 0x89, 0x0e, 0x05, 0x4f, 0x2e,
	0x89, 0x16, 0x07, 0x4f, 0xbe, 0x24, 0x00, 0xc6,
	0x84, 0x45, 0x02, 0x00, 0x4e, 0x79, 0xf8, 0x8b,
	0xf3, 0xbb, 0x08, 0x00, 0x2b, 0xf3, 0x4b, 0x2e,
	0x8a, 0x00, 0x88, 0x87, 0x46, 0x02, 0x75, 0xf6,
	0xc6, 0x06, 0x4e, 0x02, 0x20, 0xc6, 0x06, 0x4f,
	0x02, 0x20, 0xc6, 0x06, 0x50, 0x02, 0x20, 0xb4,
	0x0f, 0x8d, 0x16, 0x45, 0x02, 0xcd, 0x21, 0x3c,
	0x00, 0x74, 0x28, 0xe8, 0xc1, 0xfc, 0x0d, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x57, 0x52,
	0x4f, 0x4e, 0x47, 0x20, 0x44, 0x49, 0x53, 0x4b,
	0x00, 0xe8, 0x11, 0xfc, 0x3d, 0x1b, 0xff, 0x75,
	0xf8, 0xeb, 0xcc, 0x2e, 0x8b, 0x16, 0x07, 0x4f,
	0x1e, 0x81, 0x3e, 0x46, 0x02, 0x50, 0x49, 0x75,
	0x05, 0xb8, 0x00, 0xb8, 0x8e, 0xd8, 0xb4, 0x1a,
	0xcd, 0x21, 0x1f, 0x8d, 0x16, 0x45, 0x02, 0x2e,
	0x8b, 0x0e, 0x05, 0x4f, 0xc7, 0x06, 0x53, 0x02,
	0x01, 0x00, 0x2e, 0x8a, 0x26, 0x04, 0x4f, 0xcd,
	0x21, 0x8d, 0x16, 0x45, 0x02, 0xb4, 0x10, 0xcd,
	0x21
};

const unsigned char fileio_newdata[FILEIO_SZ] =
{
	0x83, 0xeb, 0x08,
	0x8b, 0xf3, 0x33, 0xdb, 0x2e, 0x8a, 0x00, 0x3c,
	0x20, 0x74, 0x0a, 0x88, 0x87, 0x46, 0x02, 0x43,
	0x83, 0xfb, 0x08, 0x75, 0xef, 0xc6, 0x87, 0x46,
	0x02, 0x00, 0xb0, 0x00, 0x80, 0xfc, 0x28, 0x75,
	0x02, 0xb0, 0x01, 0x8b, 0xf8, 0x8b, 0xda, 0xba,
	0x46, 0x02, 0xb4, 0x3d, 0xcd, 0x21, 0x72, 0x13,
	0xeb, 0x39, 0x90, 0x90, 0x90, 0x90, 0x90, 0x8b,
	0xc7, 0xeb, 0xef, 0x90, 0x90, 0x90, 0x90, 0x90,
	0x90, 0x90, 0x90, 0xe8, 0xc1, 0xfc, 0x0d, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x57, 0x52,
	0x4f, 0x4e, 0x47, 0x20, 0x44, 0x49, 0x53, 0x4b,
	0x00, 0xe8, 0x11, 0xfc, 0x3d, 0x1b, 0xff, 0x75,
	0xf8, 0xeb, 0xcc, 0x8b, 0xd3, 0x8b, 0xd8, 0x1e,
	0x81, 0x3e, 0x46, 0x02, 0x50, 0x49, 0x75, 0x05,
	0xb8, 0x00, 0xb8, 0x8e, 0xd8, 0x8b, 0xc7, 0xb4,
	0x3f, 0x3c, 0x01, 0x75, 0x02, 0xb4, 0x40, 0xcd,
	0x21, 0x1f, 0xb4, 0x3e, 0xcd, 0x21, 0x90, 0x90,
	0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90,
	0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90,
	0x90
};


/* new data for Pangea Dungeon */

const unsigned char dungeon_newdata[DUNGEON_SZ] =
{ 
	0x00,0x00,0x00,0x00,
	0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
	0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
	0x80,0x40,0x40,0x40,0x80,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x80,0x40,0x80,0x40,0x80,0x00,0x80,0xe0,
	0x80,0x80,0x80,0x80,0x80,0xe0,0x80,0x80,
	0x80,0x40,0x40,0x40,0x00,0x00,0xe0,0x00,
	0x80,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,
	0x80,0x80,0x80,0x00,0x80,0xe0,0x80,0x00,
	0x80,0x80,0x80,0x00,0x80,0x00,0x80,0x00,
	0x80,0x00,0x00,0x00,0xe0,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x80,0x00,0x80,0x00,
	0x80,0x00,0x80,0xe0,0x80,0x00,0x80,0x80,
	0x80,0x80,0x80,0x80,0x80,0xc0,0x80,0x80,
	0x80,0x00,0xe0,0x00,0x00,0x00,0x80,0x00,
	0x00,0x00,0xc0,0x00,0x00,0x00,0x80,0x00,
	0x80,0x00,0x80,0x80,0x80,0x00,0x80,0x00,
	0x80,0x80,0x80,0x00,0x80,0x80,0x80,0x00,
	0x80,0x00,0x80,0x00,0x80,0x00,0x80,0x00,
	0x80,0x00,0x00,0x00,0x00,0x00,0x80,0x00,
	0x80,0x00,0x80,0x00,0x80,0x00,0x80,0xc0,
	0x80,0x00,0x80,0x80,0x80,0xc0,0x80,0x00,
	0x80,0x00,0x80,0x00,0x00,0x00,0x80,0x00,
	0x00,0x00,0x80,0x10,0x00,0x00,0x80,0x00,
	0x80,0x00,0x80,0x00,0x80,0x80,0x80,0x00,
	0x80,0x00,0x80,0x00,0x80,0xe0,0x80,0x00,
	0x80,0x00,0xe0,0x00,0x00,0x00,0xc0,0x00,
	0x80,0x00,0xc0,0x00,0xe0,0x00,0x00,0x00,
	0x80,0x00,0x80,0xe0,0x80,0x80,0x80,0x80,
	0x80,0x80,0x80,0x80,0x80,0x00,0x80,0x00,
	0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};


/* new data for Pangea Map */

const unsigned char pangea_newdata = 0x24;


/* offsets */

const long gmap_offset = 0x73E8;
const long overflow_offset = 0x08ac;
const long piccas_offset = 0x06a6;
const long dungeon_offset = 0x0EFC;
const long pangea_offset = 0x021F;
const long fileio_offset = 0x54d5;


#endif
