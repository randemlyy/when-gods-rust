MODULAR BLUEPRINT KIT
=====================

Thank you for donwloading the Modular Blueprint Kit!

24 modular low-poly pieces with a blueprint grid aesthetic.
Floors, walls, ramps, doors, and windows that snap to a 1m grid.


FOLDER STRUCTURE
----------------

glTF/         - glTF files for Godot, web, any glTF viewer
_textures.    - 3 texture options

Each folder contains:
  - 24 model files (4 floors, 11 walls, 9 ramps)
  - 2 textures per color palette (6 total)


COLOR PALETTES
--------------

3 color palettes are included:

  Blue (default):
    BLUE_prototype_grid_main.png
    BLUE_prototype_grid_floor.png

  Green:
    GREEN_prototype_grid_main.png
    GREEN_prototype_grid_floor.png

  Yellow:
    YELLOW_prototype_grid_main.png
    YELLOW_prototype_grid_floor.png

All models reference the default textures (prototype_grid_main.png
and prototype_grid_floor.png). To switch colors:

  1. Delete the current default textures:
    - prototype_grid_main.png
    - prototype_grid_floor.png
  2. Copy the color you want to the glTF folder and rename them to:
     - YELLOW_prototype_grid_main.png => prototype_grid_main.png
     - YELLOW_prototype_grid_floor.png => prototype_grid_floor.png
  3. Reload the project


CUSTOM COLORS
-------------

Want your own color? Edit or replace the two texture files:

  prototype_grid_main.png  - used by walls and ramps (square grid)
  prototype_grid_floor.png - used by floors (lighter square grid)

Any image editor works. Just keep the same filename and resolution.
Every piece in the kit shares these textures, so one edit changes
everything.


GRID SPECIFICATIONS
-------------------

  Grid unit:          1 meter
  Wall height:        3m
  Floor thickness:    0.5m
  Full level height:  3.5m (wall + floor)
  Naming convention:  TYPE_SIZE_VARIANT


PIECE LIST
----------

Floors (4):   FL_1X1, FL_2X2, FL_4X4, FL_8X8
Walls (11):   WL_1X1, WL_1X2, WL_1X4,
              WL_1X1_HALF, WL_1X2_HALF, WL_1X4_HALF,
              WL_CORNER, WL_CROSS, WL_TJUNCTION,
              WL_DOOR, WL_WINDOW
Ramps (9):    RP_1X2, RP_1X4, RP_1X6,
              RP_2X2, RP_2X4, RP_2X6,
              RP_4X2, RP_4X4, RP_4X6


LICENSE
-------

You can use this kit in personal and commercial projects
(games, renders, videos, etc.). Please don't resell or
redistribute the raw asset files on their own.

If you make something cool with it, I'd love to see it!


FEEDBACK
--------

I'm always open to feedback, suggestions, and feature requests.
Feel free to reach out:

  itch.io:   https://tuily.itch.io/
  Bluesky:   https://bsky.app/profile/tuily.bsky.social
