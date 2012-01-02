
		**** The Exodus Project:  ***
		*     Ultima II Upgrade     *
		*                           *
		*        Release 1.1        *
		*****************************


Table of Contents:

	1 - Disclaimer
	2 - Project Scope
	3 - Current Features
	4 - Installation Instructions
	5 - More Information
	6 - Credits
	7 - Contact Info
	8 - Nifty Quote


1 - Disclaimer:

	Please note that Ultima is a registered trademark of Origin
	Systems, Inc (OSI), which is now a part of EA Games.  This
	project is not affiliated with nor endorsed by OSI/EA.  You
	must own a legal copy of Ultima II: Revenge of the Enchantress
	in order to apply this patch.


2 - Project Scope:

	The goal of this project is to convert Ultima II: Revenge of
	the Enchantress for the PC, a game from 1982, up to newer
	standards.

	The first phase of this project is to convert the legacy CGA
	(4-color) graphics to EGA (16-color) graphics.  I am conforming
	loosely to the Apple II color scheme, and will be using some
	tiles from the PC versions of U1 & U4.  Other goals include
	adding Quit and Restore hot keys, slowing down or controlling
	the game speed, and adding an option to disable the somewhat-
	annoying "AutoSave" feature.  As of release 1.0, this phase
	is complete!  I've also taken the liberty to modify some of
	U2's more annoying aspects for the better; for example, you
	can now save while on a mount or on other planets.

	The most recent versions of Moonstone Dragon's U2 Galaxy map
	patch (which includes some fixes to dungeon files) and Micro
	Dragon's U2 Speed Fix have been integrated into this package.

	At present, the U2 Upgrade project is in maintenance mode.
	This means that the package is stable and fairly complete.  I
	will resolve bugs as they are pointed out to me.

	Sometime in the future, I may add VGA support (256-color) to
	this upgrade.  As I am a tech and not a graphic artist, that
	phase will require the participation of others.


3 - Current Features:

	This is currently Release 1.1, which supports the following
	features:

		 1) Fully colored EGA (16-color) tiles
		 2) Colored intro/demo screens
		 3) Restore (ALT-R), Exit (ALT-X), and Main Menu (ALT-M)
		    hotkeys have been added to the game.  ALT-X is also
		    supported while at the Main Menu.
		 4) A Frame Limiter that eliminates the need for moslo
		 5) Moonstone Dragon's Galaxy Map Patch (release 10/3/97)
		 6) Micro Dragon's Speed Fix (release 2)
		 7) Improved compatibility with modern operating systems
		 8) The ability to toggle the AutoSave feature on and off
		 9) The ability to save your game on the galactic maps
		10) The ability to save your game while on board a horse,
		    ship, plane, or rocket
		11) A safeguard implemented that prevents attributes from
		    rolling beyond 99 (and back to 00)
		12) Complete conversion of text to lower-case
		13) The option to reset your game when starting a new
		    character


4 - Installation Instructions:

	1. Unpack the U2 Upgrade zip file into your Ultima 2 directory
	   on your hard drive.  This will not affect your current
	   saved games.
	2. Run "rengal.bat" if this is the first time you're applying
	   this upgrade.  This will rename the Galaxy Map files.  (It's
	   only necessary to run this once, but does not create a problem
	   if you run it again.)
	3. Run "dngpatch.exe".  This will repair the Pangea dungeon
	   and re-add the Greenland dungeon to the Pangea map.  (It's
	   only necessary to run this once, but does not create a problem
	   if you run it again.)
	4. Run "u2cfg.exe" to configure the game options.
	5. Run "ultima2.com" from the Ultima 2 directory to start the
	   game.
	6. Email me with suggestions and/or bugs.

	Optional steps:

	- You can also run "cgapatch.exe" which patches the CGA binary to
	run on modern systems.  It applies Moonstone Dragon's Galaxy Map
	Patch, Micro Dragon's Speed Fix, the PICCAS image (part of the
	Demonstration), and updated File I/O for problems with newer
	Windows operating systems.  All these patches are already applied
	to the EGA binary.


5 - More Information:

	Please read the following text files for more information on
	this packge.

	HISTORY.TXT		- History of updates to U2 Upgrade
	FILES.TXT		- Describes files in U2 Upgrade package
	GCHANGES.TXT		- Readme/Changes for Galaxy Map Patch
	U2-SPDFX.TXT		- Readme/Changes for Speed Fix


6 - Credits:

	Thanks to those before me who have contributed to Ultima II:
	Micro Dragon for his U2 Speed Fix, Moonstone Dragon for
	supplying us with the U2 Galaxy Maps, and John Alderson for
	adding comments to much of the assembly code in his U2 for
	Windows project.  Their work has saved me a lot of time.

	Thanks to the Ultima Dragons of rgcud for, well, just being the
	outspoken group that they are.

	And thanks especially to Richard Garriot for creating Ultima II
	& III in CGA, thus inspiring me to learn assembly.  ;)


7 - Contact Info:

	Please email me with comments, rants, suggestions, bugs, etc.  Do
	NOT email me for pirate copies of Ultima II (or any game for that
	matter).  (And I've given up saying "NO!" to SPAM!)

	Michael C. Maggio
	Voyager Dragon, -=(UDIC)=-
	voyager@voyd.net

	Project WebSite - http://exodus.voyd.net/


8 - Nifty Quote:

	"Parkinson's Law:  Work expands to fill the time alloted it."
