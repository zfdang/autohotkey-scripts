`start AutoHotKeyu64.exe wm4k.ahd` should launch it.  both of the files in this gist should be in the same directory.

with NUMLOCK off, pushing number keys will move windows around.  `8` will resize a window to fit 1/8th of your screen (1/4 width, 1/2 height.)

Similar operations for `1`, `2`, `3`, `4`, and `6`.  CTRL does things in combination with `3`, `4`, and `6`, so try those.

Numpad `*` (with numlock off, always) will arrange a window to occupy 1/12th of the screen (1/6th horizontally and 1/2 vertically).

NEW - `Numpad+` and `Numpad-` will adjust a window's position horizontally

Feel free to add any other combinations you want.  I don't know AHK well enough to add more.

Written by Roel Hammerschlag and modified by myself.

License: public domain

TODO:
 * support four horizontal placement rows instead of just two, to support stacking windows 3 and 4 high.
 * support nudging up and down.
