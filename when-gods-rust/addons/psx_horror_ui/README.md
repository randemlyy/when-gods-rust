# PSX Horror UI

A PS1 survival-horror menu skin for Godot 4.3+: themes as ready-made `Theme` resources with
windows, menu lines with a pointer, item boxes, an examine frame, a heart monitor, map rooms and
marks, paper for files, save slots and a message box, plus item icons, ECG traces and bar fills, a
cursor and the Ribbon bitmap font. Every image is also a plain PNG in the PS1's 15-bit colour, with
its 9-slice margins listed for any other engine.

**The full pack:** **[PSX Horror UI](https://heyheythere.itch.io/psx-horror-ui)** has five themes (mansion, fog,
lab, blood and archive) and 100 item icons at 32 and 96 pixels (handgun, revolver, magnum,
shotguns, SMG, grenades, ammo for every calibre, herbs, sprays, pills, 20 keys and keycards,
batteries, flares, files, crowbar, bolt cutters, puzzle pieces and item box). Same files and names: install it over this one.

## Use it in Godot

1. Copy `addons/psx_horror_ui/` into your project.
2. Project Settings:
   - *Rendering > Textures > Default Texture Filter*: **Nearest**, or the pixels blur.
   - *GUI > Theme > Custom*: `res://addons/psx_horror_ui/themes/mansion.tres` (or any theme), so
     every Control uses it. Or set `theme` on one Control and its children follow.
3. Draw the UI at a whole-number scale. The art is 1x (the font is 9px on a 12px line), made for a
   UI about 240 pixels high, the PS1's: set *Display > Window > Stretch > Mode* to `canvas_items`
   and either use a small viewport (for example 320x240 or 426x240), or keep yours and set
   `get_tree().root.content_scale_factor` to 3, as `demo/demo.gd` does.

## Themes

Each `themes/<name>.tres` styles Button, OptionButton, CheckBox (check and radio), Label, Panel,
PanelContainer, LineEdit, HSlider, ProgressBar, TabContainer, TabBar, PopupMenu, tooltips, scroll
bars and HSeparator. Set `theme_type_variation` for the extras:

| Variation | On | Looks like |
|---|---|---|
| `WindowPanel` | PanelContainer | a window with a title bar; its first line of content sits in the bar |
| `Title` | Label | the text for that title bar |
| `MenuItem` | Button | a menu line: a pointer and a highlight band fading right on the line hovered, focused or pressed (toggle), none otherwise |
| `ItemSlot`, `ItemSlotSelected`, `ItemSlotEquipped` | PanelContainer | a 38x38 item box round a 32px icon: plain, rimmed in the highlight colour, marked green in its corner |
| `Count` | Label | white shadowed digits for an ammo or item count |
| `ExaminePanel` | PanelContainer | a dark field with corner brackets, for a 96px icon |
| `MonitorPanel` | PanelContainer | a gridded screen for the ECG trace or the map |
| `MapRoom`, `MapRoomItems`, `MapRoomCurrent`, `MapRoomUnknown` | Panel | a room explored, explored with items left, the one you are in, not visited (dotted) |
| `DocumentPanel` | PanelContainer | a page with a folded corner, the same in every theme |
| `Ink` | Label | dark text for the page |
| `DialoguePanel` | PanelContainer | the message box: see-through, ruled above and below |
| `SaveSlot` | Button | a save slot two lines tall |
| `Headline` | Label | the font at 2x in the highlight colour, for titles |
| `Heading`, `Hint` | Label | text in the highlight colour, and dimmed |
| `Fine`, `Caution`, `Danger`, `Poison` | Label | the condition's colour |
| `FineBar`, `CautionBar`, `DangerBar`, `PoisonBar` | ProgressBar | a bar in that colour |

The map marks and the message box's arrow are icons of the theme type `Marks`, for a game to draw:
`get_theme_icon("door", "Marks")`, and `door_locked`, `save`, `item`, `you`, `next`, `pointer`.

A window: PanelContainer (`WindowPanel`) > VBoxContainer > Label (`Title`) first, then the content.
An item: PanelContainer (`ItemSlot`) > TextureRect with `icons/<name>.png`, and a `Count` Label on
it if you like.

## The heart monitor

`status/ecg_fine.png`, `ecg_caution.png`, `ecg_danger.png` and `ecg_poison.png` are 64x16 traces
that join end to end: draw one twice side by side in a `MonitorPanel` and slide it left, faster the
worse the condition (`demo/demo.gd`'s `Ecg`). `status/bar_*.png` are the bars' fills.

## Icons

100 items, each twice: `icons/<name>.png` at 32x32 for the grid and `icons/large/<name>.png` at
96x96 for the examine screen, rendered from the models of PSX Horror Props, PSX Firearms and PSX
Survival Pickups (https://heyheythere.itch.io) and cut to 15-bit colour with the PS1's dither. `icons/_sheet.png`
has the small ones on one 6-column sheet. The themes leave Button icons untinted.

## Other engines

Every part is a PNG in `themes/<name>/`. `themes/slices.json` lists each one's 9-slice borders
(left, top, right, bottom, in pixels; the same in every theme). Where a middle is **tiled**, repeat
it rather than stretch it, or its dither smears:

| Parts | Borders |
|---|---|
| `button_*` | 4, 7, 4, 8, middle tiled across |
| `save_slot_*` | 6, 12, 6, 13, middle tiled across |
| `menu_band` | 4, 6, 16, 7, middle tiled across (the right border is the fade) |
| `panel` | 5, 5, 5, 5 |
| `window` | 5, 18, 5, 5 (the title bar is rows 3 to 14), middle tiled across |
| `slot`, `slot_selected`, `slot_equipped` | 5, 18, 5, 19, middle tiled across |
| `examine` | 12, 12, 12, 12 |
| `dialogue` | 12, 4, 12, 4 |
| `monitor` | 4, 4, 4, 4, middle tiled both ways |
| `document` | 6, 12, 6, 12, middle tiled both ways |
| `map_room*` | 3, 3, 3, 3 |
| `divider` | 8, 0, 8, 0 (5 rows tall) |
| `focus` | 3, 3, 3, 3 |
| `line_edit`, `tooltip` | 4, 4, 4, 4 |
| `progress_bg` | 4, 3, 4, 3 |
| `progress_fill`, `status/bar_*` | 3, 2, 3, 2, drawn over the whole bar: their colour sits inside `progress_bg`'s frame |
| `slider`, `slider_fill` | 3, 2, 3, 2 |
| `tab_selected` | 4, 4, 4, 1 |
| `tab_unselected`, `tab_hover` | 4, 5, 4, 2 |
| `scroll*`, `menu_hover` | 2, 2, 2, 2 |

The rest are drawn as they are: `checkbox_*` and `radio_*` (11x11), `grabber*` (7x11), `arrow`
(the option button's, 7x4), `pointer` (6x11), `next` (7x5) and the `mark_*` map marks.

## Files

- `themes/<name>.tres` and `themes/<name>/*.png`: the Theme and its parts.
- `icons/*.png`, `icons/large/*.png`: the items, on a transparent background.
- `status/ecg_*.png`, `status/bar_*.png`: the heart monitor's traces and the bars' fills.
- `cursor.png` and `cursor_2x/3x/4x.png`: a pointer, hotspot at the top-left pixel. The OS draws
  cursors unscaled, so pick the copy that matches your UI scale for *Display > Mouse Cursor >
  Custom Image*.
- `font/psx_horror_ui_font.fnt`: Ribbon, a proportional typewriter BMFont with printable ASCII and
  Latin-1, 9px on a 12px line; `font/psx_horror_ui_font_2x.fnt` is the same at 18px on 24, which
  `Headline` uses. Keep each at its size and scale the UI instead.
