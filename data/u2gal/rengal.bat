@echo off


echo Renaming all MAP files...
if not exist MAPG44 ren MAPX44 MAPG44
if not exist MAPG50 ren MAPX50 MAPG50
if not exist MAPG60 ren MAPX60 MAPG60
if not exist MAPG61 ren MAPX61 MAPG61
if not exist MAPG70 ren MAPX70 MAPG70
if not exist MAPG71 ren MAPX71 MAPG71
if not exist MAPG80 ren MAPX80 MAPG80
if not exist MAPG81 ren MAPX81 MAPG81
if not exist MAPG82 ren MAPX82 MAPG82
if not exist MAPG85 ren MAPX85 MAPG85
if not exist MAPG90 ren MAPX90 MAPG90
if not exist MAPG92 ren MAPX92 MAPG92
if not exist MAPG93 ren MAPX93 MAPG93

echo Renaming all MON files...
if not exist MONG44 ren MONX44 MONG44
if not exist MONG50 ren MONX50 MONG50
if not exist MONG60 ren MONX60 MONG60
if not exist MONG61 ren MONX61 MONG61
if not exist MONG70 ren MONX70 MONG70
if not exist MONG71 ren MONX71 MONG71
if not exist MONG80 ren MONX80 MONG80
if not exist MONG81 ren MONX81 MONG81
if not exist MONG82 ren MONX82 MONG82
if not exist MONG85 ren MONX85 MONG85
if not exist MONG90 ren MONX90 MONG90
if not exist MONG92 ren MONX92 MONG92
if not exist MONG93 ren MONX93 MONG93

echo Creating additional MON files...
if not exist MONG10 copy MONG20 MONG10 /y
if not exist MONG15 copy MONG20 MONG15 /y
if not exist MONG30 copy MONG20 MONG30 /y
if not exist MONG40 copy MONG20 MONG40 /y
if not exist MONG45 copy MONG20 MONG45 /y

echo Deleting unneeded TLK files...
if exist TLKX61 del TLKX61
if exist TLKX71 del TLKX71
if exist TLKX81 del TLKX81
if exist TLKX82 del TLKX82
if exist TLKX92 del TLKX92
if exist TLKX93 del TLKX93


echo Galaxy Maps applied
