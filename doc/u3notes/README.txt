
                        **** The Exodus Project: ****
                        *    Ultima III Upgrade     *
                        *  http://exodus.voyd.net/  *
                        *****************************

Installation:

    1) Run the following program to patch the game, depending on your O/S:
        * Windows:  u3upw   (Can be launched directly from explorer)
        * DOS:      u3up
    2) Edit dosbox.conf (dosboxULTIMA3.conf for GOG) and change these values:
        * cycles=10000   (or greater)
        * cputype=auto
    3) Run ULTIMA3.COM in DOSBOX to start the game.
        * For GOG, edit dosboxULTIMA3_single.conf and change the line that
          reads 'ultima.com' to 'ULTIMA3.COM'.

Optional Steps:

    *) Run the following program to change the default configuration:
        * Windows:  u3cfgw   (Can be launched directly from explorer)
        * DOS:      u3cfg

---

If upgrading from U3 Upgrade v3.2 or earlier:

    *) Do NOT use 'u3reset' from earlier versions.  This tool is now obsolete
       and incompatible with the Upgrade patch.
    *) DPMI is no longer needed to run the Upgrade tools.

If upgrading from floppy releases:

    *) Please copy the contents of all disks to the hard drive.
