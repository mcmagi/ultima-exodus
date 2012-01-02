
		**** The Exodus Project ****
		*    Ultima III Upgrade    *
		*                          *
		*        Release 2.5       *
		****************************


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
	Systems, Inc (OSI).  This project is not affiliated with nor
	endorsed by OSI.  You must own a legal copy of Ultima III:
	Exodus in order to apply this patch.


2 - Project Scope:

	The goal of this project is to convert Ultima III: Exodus
	for the PC up to newer standards.

	The first phase of this project was to convert the legacy
	CGA (4-color) graphics to lesser-legacy EGA (16-color)
	graphics.  Let's face it: magenta, cyan, and grey were not
	exactly pleasing to the eye.  I conformed loosely to the
	C64 color scheme, and used some tiles from the PC versions
	of U1 & U4.  (As of v1.0, this phase is complete!)

	The second phase will add MIDI music to the game. Many
	thanks go to Aradindae Dragon (maker of the U4 MIDI
	Upgrade) for supplying me with the MIDI package in the
	first place.  (As of v2.0, this phase is complete!)

	The third phase of this project will add VGA (256-color)
	graphics to the game.  Having a series of successes with
	other upgrade projects, I have learned quite a bit more
	about assembly language since I first started this hobby,
	so it is my hope to also change the architecture to be more
	driver-oriented during this next phase.  This will allow
	for easier maintenance in the future.

	Other goals that are not necessarily part of any particular
	phase include adding Quit and Restore hot keys, slowing
	down or controlling the game speed, and possibly adding an
	option to disable the annoying "AutoSave" feature.  (As of
	v2.1, all these features have been added!)


3 - Current Features:

	This is currently Release 2.5, which supports the following
	features:

		1) Fully colored EGA (16-color) tiles
		2) Dungeons are also in color
		3) Peer Gems yield a multi-colored look at the world
		   map, versus only texture in the CGA, C64, and Apple
		   II versions
		4) Restore (ALT-R), Exit (ALT-X), and Main Menu (ALT-M)
		   hotkeys have been added to the game.  ALT-X is also
		   supported while at the Main Menu.
		5) A Frame Limiter that eliminates the need for moslo
		6) Enhanced MIDI Music from the C64 and Apple II versions
		7) Ability to Enable/Disable the AutoSave feature


4 - Installation Instructions:

	1. The PC version of Ultima 3 must already be installed on
	   your hard drive.
	2. Unzip the U3 Upgrade zip file into your Ultima 3 directory
	   on your hard drive.  This will not affect your current
	   installation or saved games.
	3. Run SETM.EXE from the Ultima 3 directory to configure
	   your sound card, if you will be playing music.
	4. Run U3CFG.EXE to configure the game options.  By
	   default, MIDI is enabled, AutoSave is disabled, and the
	   Frame Limiter is enabled.
	5. Run ULTIMA3.COM from the Ultima 3 directory to start the
	   game.
	6. Email me with suggestions and/or bugs.

	Optional steps:

	- You can run U3RESET.EXE to reset the game map if you want
	your party to enter an uncharted Sosaria.  Your party must
	be dispersed in order to clear the map.  This program will
	not affect the Roster.


5 - More Information:

	Please read the following text files for more information on
	this packge.

	HISTORY.TXT		- History of updates to U3 Upgrade
	FILES.TXT		- Describes files in U3 Upgrade package


6 - Credits:

	Thanks to all the people who have submitted comments, suggestions, 
	and bug reports thus far.  Your comments are greatly appreciated,
	and have helped to make this a better upgrade to a great game!

	Thanks twofold to Aradindae Dragon (Ryan Wiener) for a) supplying
	me with the Midpak drivers and b) helping me to get them working
	properly.

	Thanks to the Ultima Dragons of rgcud for, well, just being the
	outspoken group that they are.

	And thanks especially to Richard Garriot for creating Ultima III
	in CGA, thus inspiring me to learn assembly.  ;)


7 - Contact Info:

	Please email me with comments, rants, suggestions, bugs, etc.  Do
	NOT email me for pirate copies of Ultima III (or any game for that
	matter).  And say "NO!" to SPAM!

	Michael C. Maggio
	Voyager Dragon, -=(UDIC)=-
	voyager@voyd.net

	Project WebSite - http://exodus.voyd.net/


8 - Nifty Quote:

	"Truly great madness can not be achieved without significant
	 intelligence."
		-- Henrik Tikkanen
