#ifndef	_U3_RESET_DEFS
#define	_U3_RESET_DEFS


/* sizes */
#define	PARTY_SZ			276
#define	SOSARIA_SZ		4648
#define	MAP_SZ			0x1000
#define	NUM_MONS			32
#define	NUM_COLS			64
#define	MON_SZ			NUM_MONS * 5
#define	MOON_SZ			4
#define	WHIRL_SZ			4


/* offsets */
#define	MAP_OFF			0x0
#define	NUM_PARTY_OFF		0x7
#define	MON_OFF			0x1180
#define	WHIRL_OFF 		0x1220
#define	MOON_OFF			0x1224


/* tiles */
#define	WATER_TILE		0x00
#define	GRASS_TILE		0x04
#define	BRUSH_TILE		0x08
#define	FOREST_TILE		0x0c
#define	HORSE_TILE		0x28
#define	FRIGATE_TILE		0x2c
#define	WHIRLPOOL_TILE		0x30
#define	MOONGATE_TILE		0x88


/* data */
#define	WHIRL_COL 		0x05
#define	WHIRL_ROW 		0x3a

const unsigned char whirl_data[WHIRL_SZ] = { WHIRL_COL, WHIRL_ROW, 0x0c, 0x04 };
const unsigned char moon_data[MOON_SZ] = { 0x00, 0x00, 0x0c, 0x04 };


#endif
