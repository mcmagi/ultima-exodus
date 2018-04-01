@echo off


echo Renaming all MAP files...
if not exist mapg44 ren mapx44 mapg44
if not exist mapg50 ren mapx50 mapg50
if not exist mapg60 ren mapx60 mapg60
if not exist mapg61 ren mapx61 mapg61
if not exist mapg70 ren mapx70 mapg70
if not exist mapg71 ren mapx71 mapg71
if not exist mapg80 ren mapx80 mapg80
if not exist mapg81 ren mapx81 mapg81
if not exist mapg82 ren mapx82 mapg82
if not exist mapg85 ren mapx85 mapg85
if not exist mapg90 ren mapx90 mapg90
if not exist mapg92 ren mapx92 mapg92
if not exist mapg93 ren mapx93 mapg93

echo Renaming all MON files...
if not exist mong44 ren monx44 mong44
if not exist mong50 ren monx50 mong50
if not exist mong60 ren monx60 mong60
if not exist mong61 ren monx61 mong61
if not exist mong70 ren monx70 mong70
if not exist mong71 ren monx71 mong71
if not exist mong80 ren monx80 mong80
if not exist mong81 ren monx81 mong81
if not exist mong82 ren monx82 mong82
if not exist mong85 ren monx85 mong85
if not exist mong90 ren monx90 mong90
if not exist mong92 ren monx92 mong92
if not exist mong93 ren monx93 mong93

echo Creating additional MON files...
if not exist mong10 copy mong20 mong10 /y
if not exist mong15 copy mong20 mong15 /y
if not exist mong30 copy mong20 mong30 /y
if not exist mong40 copy mong20 mong40 /y
if not exist mong45 copy mong20 mong45 /y

echo Deleting unneeded TLK files...
if exist tlkx61 del tlkx61
if exist tlkx71 del tlkx71
if exist tlkx81 del tlkx81
if exist tlkx82 del tlkx82
if exist tlkx92 del tlkx92
if exist tlkx93 del tlkx93


echo Galaxy Maps applied
