
                        **** The Exodus Project: ****
                        *     Ultima II Upgrade     *
                        *  http://exodus.voyd.net/  *
                        *****************************

Installation:

    1) Run the following program to patch the game, depending on your O/S:
        * Windows:  u2upw   (Can be launched directly from explorer)
        * DOS:      u2up
    2) Edit dosbox.conf (dosboxULTIMA2.conf for GOG) and change these values:
        * cycles=3000   (or greater)
        * cputype=auto
    3) Run ULTIMA2.COM in DOSBOX to start the game.
        * For GOG, edit dosboxULTIMA2_single.conf and change the line that
          reads 'ultimaII.exe' to 'ULTIMA2.COM'.

Optional Steps:

    *) Run the following program to change the default configuration:
        * Windows:  u2cfgw   (Can be launched directly from explorer)
        * DOS:      u2cfg

---

Notes:

    *) Do NOT use 'u2reset', 'rengal', 'cgapatch' or 'dngpatch' from v1.1.
       These tools are now obsolete and incompatible with the Upgrade patch.
    *) DPMI is no longer needed to run the upgrade tools.
    *) The install may fail from U2 Upgrade v1.1. If so you will need to
       reinstall the game. Apologies, but v1.1 is a bit of a special case.
