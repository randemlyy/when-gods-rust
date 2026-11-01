extends Control
## The kit in use: a survival-horror game's screens (title, a line of dialogue, the items, examining
## one, the map, the files, the typewriter save and the pause menu), all plain Controls styled by
## one Theme. The menu on the left changes the screen, the buttons along the bottom the theme.

const KIT := "res://addons/psx_horror_ui/"
const ALL_THEMES: Array[String] = ["mansion", "fog", "lab", "blood", "archive"]
const ART_HEIGHT := 240.0
const FIRST := "mansion"
const SCREENS: Array[String] = ["title", "game", "items", "examine", "map", "files", "save", "options"]
const CONDITIONS: Array[String] = ["fine", "caution", "danger", "poison"]
## name: [label, description, what checking it turns up]
const ITEMS := {
	"pistol": ["Handgun", "A 9mm service pistol. Fifteen rounds to a magazine.", "The serial number has been filed off."],
	"pump_shotgun": ["Shotgun", "A pump-action shotgun. Slow, loud and very persuasive.", "There's a name scratched into the stock: K. Ward."],
	"ammo_handgun": ["Handgun Ammo", "A box of 9mm rounds for the handgun.", "Twenty-two rounds left in the box."],
	"herb": ["Green Herb", "A potted herb with a bitter smell. Restores a little health.", "Some leaves have been torn off already."],
	"first_aid_kit": ["First Aid Kit", "Bandages, gauze and antiseptic. Restores all health.", "A label inside the lid: WARD C."],
	"key_skeleton": ["Old Key", "An iron key, worn smooth. There is a crest on the bow.", "There is a heart carved into the crest."],
	"flashlight": ["Flashlight", "It flickers when shaken. The batteries are nearly gone.", "Something is taped inside the battery cover."],
	"keycard_red": ["Red Keycard", "A security card for the east lab.", "The photo on it has been scratched out."],
	"crank_handle": ["Crank Handle", "An iron crank with a square socket.", "It would fit the shutter in the kitchen."],
	"fuse": ["Fuse", "A ceramic fuse. Still good.", "Rated for the generator in the basement."],
	"ink_ribbon": ["Ink Ribbon", "A typewriter ribbon. Use one at a typewriter to save.", "Enough ink for one entry."],
	"typewriter": ["Typewriter", "An old office typewriter with a sheet already in.", "The last line typed: DON'T OPEN THE LAB."],
}
const BAG: Array = [["pistol", 15], ["pump_shotgun", 6], ["ammo_handgun", 22], ["herb", 2], ["first_aid_kit", 0],
	["flashlight", 0], ["", 0], ["", 0]]
const KEY_ITEMS: Array = [["key_skeleton", 0], ["keycard_red", 0], ["crank_handle", 0], ["fuse", 0], ["", 0], ["", 0],
	["", 0], ["", 0]]
const FILES := {
	"Diary": "May 9\nThe subject in cell 4 has stopped eating. Dr. Ash says this is expected.\n\nMay 11\nIt scratched at the glass all night. I asked to be moved to the west wing.\n\nMay 12\nItchy. Itchy. The guard left the east door open.",
	"Staff Memo": "To all night staff:\n\nThe east wing is closed until further notice. Keycards for the lab are held at the security desk.\n\nDo not answer the phone in the gallery.",
	"Patient Log": "Room 3 - sedated\nRoom 4 - restless, fever\nRoom 5 - empty (?)\nRoom 6 - do not enter\n\nThe herbs in the greenhouse help the fever. Nothing helps room 6.",
	"Torn Page": "...the crest on the old key matches the door in the dining room. The heart, the spade, the club and the diamond. Four doors, four keys, and behind the last...",
}
const LINES: Array = [
	["", "The door is locked. There is a heart carved above the keyhole."],
	["Nurse Hale", "You're alive... Stay out of the east wing. Whatever got out of the lab is still in there."],
	["", "There is a first aid kit on the table. Will you take it?"],
]

const UNIT := 7  # the map's squares, in pixels
## The map's rooms: x, y, w, h in squares, then their variation and name.
const ROOMS: Array = [[1, 1, 6, 8, "MapRoom", "West Gallery"], [7, 3, 5, 4, "MapRoomItems", "Dining Room"],
	[12, 1, 6, 8, "MapRoomCurrent", "Main Hall"], [7, 7, 3, 3, "MapRoom", "Safe Room"],
	[18, 4, 10, 2, "MapRoom", "East Corridor"], [28, 1, 7, 6, "MapRoomUnknown", "Library"],
	[20, 6, 4, 5, "MapRoomItems", "Kitchen"], [28, 7, 7, 11, "MapRoomUnknown", "Laboratory"],
	[12, 9, 6, 4, "MapRoom", "Stairs"], [1, 9, 6, 6, "MapRoomUnknown", "Greenhouse"], [24, 11, 4, 3, "MapRoom", "Storage"]]
## The map's marks: which, and where in squares.
const MARKS: Array = [[&"door", 12, 5], [&"door", 18, 5], [&"door_locked", 28, 5], [&"door", 8.5, 7],
	[&"door", 22, 6], [&"door", 15, 9], [&"door_locked", 4, 9], [&"save", 8.5, 8.7], [&"item", 9.5, 5],
	[&"item", 22, 8.5], [&"you", 15, 4.5], [&"door", 24, 12.5]]

## Store captures: the screen to open on.
@export var screen := "items"
## Store capture only: move on to the next screen and theme every this many frames.
@export var cycle_frames := 0

var frame := 0
var theme_buttons := {}
var screens := {}
var nav := {}
var selected := "herb"
var slots := {}
var line := 0


## Draws the UI at a whole-number scale so the art pixels stay square: the largest that still
## fits `art_height` pixels of art on screen.
static func pixel_scale(node: Node, art_height: float) -> void:
	var window := node.get_tree().root
	window.content_scale_factor = 1.0
	window.content_scale_factor = maxf(1.0, floorf(window.get_visible_rect().size.y / art_height))


static func themes() -> Array[String]:
	var installed: Array[String] = []
	for n in ALL_THEMES:
		if ResourceLoader.exists(KIT + "themes/%s.tres" % n):
			installed.append(n)
	return installed


## The named theme, or the first one installed.
static func kit_theme(name: String) -> Theme:
	return load(KIT + "themes/%s.tres" % (name if name in themes() else themes()[0]))


## The item's 32px icon, or its 96px one; null when it isn't installed.
static func icon_texture(name: String, large := false) -> Texture2D:
	var path := KIT + ("icons/large/%s.png" if large else "icons/%s.png") % name
	return load(path) if ResourceLoader.exists(path) else null


static func icon(name: String, large := false) -> TextureRect:
	var t := TextureRect.new()
	t.texture = icon_texture(name, large)
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	t.custom_minimum_size = Vector2.ONE * (96 if large else 32)
	return t


## A titled window; add its content to the returned VBox.
static func window(parent: Control, title: String, at := Vector2.ZERO, width := 0.0) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"WindowPanel"
	panel.position = at
	panel.custom_minimum_size.x = width
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	label(box, title, &"Title")
	return box


static func panel(parent: Control, variation: StringName, at := Vector2.ZERO) -> PanelContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = variation
	p.position = at
	parent.add_child(p)
	return p


static func row(parent: Control, separation := 4) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", separation)
	parent.add_child(h)
	return h


static func column(parent: Control, separation := 4) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", separation)
	parent.add_child(v)
	return v


static func label(parent: Control, text: String, variation := &"", wrap := 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	if wrap > 0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = wrap
	parent.add_child(l)
	return l


## A menu line: the pointer and the band show on the one the player is on.
static func menu_item(parent: Control, text: String, group: ButtonGroup = null) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = &"MenuItem"
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if group:
		b.toggle_mode = true
		b.button_group = group
	parent.add_child(b)
	return b


## A 38x38 item box ("", "selected" or "equipped") holding a 32px icon and a count above 0.
static func slot(parent: Control, item: String, count := 0, kind := "") -> PanelContainer:
	var s := PanelContainer.new()
	s.theme_type_variation = {"": &"ItemSlot", "selected": &"ItemSlotSelected", "equipped": &"ItemSlotEquipped"}[kind]
	s.custom_minimum_size = Vector2(38, 38)
	parent.add_child(s)
	if item == "" or icon_texture(item) == null:
		return s
	var art := icon(item)
	art.tooltip_text = ITEMS[item][0] if item in ITEMS else item.capitalize()
	s.add_child(art)
	if count > 0:
		var n := Label.new()
		n.text = str(count)
		n.theme_type_variation = &"Count"
		art.add_child(n)
		n.position = Vector2(32 - n.get_minimum_size().x, 21)
	return s


static func bar(parent: Control, condition: String, value: float, width := 0.0) -> ProgressBar:
	var b := ProgressBar.new()
	b.theme_type_variation = StringName(condition.capitalize() + "Bar")
	b.show_percentage = false
	b.value = value
	b.custom_minimum_size = Vector2(width, 10)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(b)
	return b


func _ready() -> void:
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST  # project.godot's, for a project without it
	pixel_scale(self, ART_HEIGHT)
	add_child(Backdrop.new())
	theme = kit_theme(FIRST)
	var menu := window(self, "Menu", Vector2(4, 4), 72)
	menu.add_theme_constant_override("separation", 0)
	var group := ButtonGroup.new()
	for s in SCREENS:
		var b := menu_item(menu, s.capitalize(), group)
		b.toggled.connect(func(on: bool) -> void:
			if on:
				show_screen(s))
		nav[s] = b
	var area := Control.new()
	area.position = Vector2(80, 4)
	area.size = Vector2(342, 214)
	add_child(area)
	for s in SCREENS:
		var c := Control.new()
		c.size = area.size
		area.add_child(c)
		screens[s] = c
		call("_" + s, c)
	var switcher := row(self, 2)
	switcher.position = Vector2(4, 222)
	var themes_group := ButtonGroup.new()
	for name in themes():
		var b := Button.new()
		b.text = name.capitalize()
		b.toggle_mode = true
		b.button_group = themes_group
		b.button_pressed = name == kit_theme(FIRST).resource_path.get_file().get_basename()
		b.toggled.connect(func(on: bool) -> void:
			if on:
				theme = kit_theme(name))
		switcher.add_child(b)
		theme_buttons[name] = b
	nav[screen if screen in SCREENS else "items"].button_pressed = true


func show_screen(s: String) -> void:
	for name in screens:
		screens[name].visible = name == s
	nav[s].set_pressed_no_signal(true)


func _process(_delta: float) -> void:
	if cycle_frames <= 0:
		return
	frame += 1
	if frame % cycle_frames == 0:
		var step := frame / cycle_frames
		var names := themes()
		theme_buttons[names[(maxi(0, names.find(FIRST)) + step) % names.size()]].button_pressed = true
		nav[SCREENS[(SCREENS.find(screen) + step) % SCREENS.size()]].button_pressed = true


func _title(c: Control) -> void:
	var box := column(c, 1)
	label(box, "THE HOLLOW HOUSE", &"Headline").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(box, "a survival horror", &"Hint").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 40)
	var items := column(c, 0)
	items.custom_minimum_size.x = 84
	var group := ButtonGroup.new()
	for t in ["New game", "Continue", "Load game", "Options", "Quit"]:
		var b := menu_item(items, t, group)
		b.button_pressed = t == "New game"
		b.disabled = t == "Continue"
	items.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 96)
	label(c, "PRESS START", &"Hint").set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM,
		Control.PRESET_MODE_MINSIZE, 12)


func _game(c: Control) -> void:
	var hud := row(c, 4)
	hud.position = Vector2(4, 4)
	var monitor := Condition.new()
	monitor.state = "caution"
	hud.add_child(monitor)
	slot(hud, "pistol", 15, "equipped").size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var box := panel(c, &"DialoguePanel", Vector2(6, 146))
	box.custom_minimum_size = Vector2(330, 52)
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.tooltip_text = "Click to read on"
	var text := column(box, 1)
	var speaker := label(text, "", &"Heading")
	var said := label(text, "", &"", 300)
	var choice := row(text, 8)
	for t in ["Yes", "No"]:
		menu_item(choice, t).custom_minimum_size.x = 40
	var next := Mark.new(&"next")
	next.size_flags_horizontal = Control.SIZE_SHRINK_END
	next.size_flags_vertical = Control.SIZE_SHRINK_END
	box.add_child(next)
	var say := func() -> void:
		speaker.text = LINES[line][0]
		speaker.visible = LINES[line][0] != ""
		said.text = LINES[line][1]
		choice.visible = line == LINES.size() - 1
		next.blink = not choice.visible
	say.call()
	box.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			line = (line + 1) % LINES.size()
			say.call())


func _items(c: Control) -> void:
	var left := column(c, 4)
	var status := window(left, "Condition", Vector2.ZERO, 96)
	var monitor := Condition.new()
	monitor.with_bar = true
	status.add_child(monitor)
	var gun := window(left, "Equipped", Vector2.ZERO, 96)
	var r := row(gun)
	slot(r, "pistol", 15, "equipped")
	var info := column(r, 0)
	label(info, "Handgun")
	label(info, "15/15", &"Hint")
	var bag := window(c, "Items", Vector2(100, 0), 170)
	var tabs := TabContainer.new()
	bag.add_child(tabs)
	for page in [["Items", BAG], ["Key items", KEY_ITEMS]]:
		var grid := GridContainer.new()
		grid.name = page[0]
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 2)
		grid.add_theme_constant_override("v_separation", 2)
		tabs.add_child(grid)
		for it in page[1]:
			var s := slot(grid, it[0], it[1])
			if it[0] == "":
				continue
			slots[it[0]] = s
			s.gui_input.connect(func(e: InputEvent) -> void:
				if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and s.get_child_count() > 0:
					_select(it[0]))
	bag.add_child(HSeparator.new())
	label(bag, "", &"Heading").name = "Name"
	label(bag, "", &"", 158).name = "Text"
	var actions := window(c, "Command", Vector2(274, 0), 68)
	actions.add_theme_constant_override("separation", 0)
	for t in ["Use", "Equip", "Examine", "Combine", "Discard"]:
		var b := menu_item(actions, t)
		if t == "Examine":
			b.pressed.connect(func() -> void: nav["examine"].button_pressed = true)
	_select(selected)


func _select(item: String) -> void:
	selected = item
	for n in slots:
		slots[n].theme_type_variation = &"ItemSlotSelected" if n == item else &"ItemSlot"
	var bag: Control = screens["items"].get_child(1).get_child(0)
	(bag.get_node("Name") as Label).text = ITEMS[item][0]
	(bag.get_node("Text") as Label).text = ITEMS[item][1]
	if screens.has("examine"):
		_show_examined()


func _examine(c: Control) -> void:
	var view := panel(c, &"ExaminePanel", Vector2(91, 0))
	view.custom_minimum_size = Vector2(160, 124)
	var art := icon(selected, true)
	art.name = "Art"
	view.add_child(art)
	var box := panel(c, &"DialoguePanel", Vector2(16, 130))
	box.custom_minimum_size.x = 310
	var text := column(box, 1)
	label(text, "", &"Heading").name = "Name"
	label(text, "", &"", 288).name = "Text"
	var buttons := row(c, 4)
	buttons.position = Vector2(111, 186)
	for t in ["Check", "Back"]:
		var b := Button.new()
		b.text = t
		b.custom_minimum_size.x = 58
		buttons.add_child(b)
		b.pressed.connect(func() -> void:
			if t == "Back":
				nav["items"].button_pressed = true
			else:
				(text.get_node("Text") as Label).text = ITEMS[selected][2])
	_show_examined()


func _show_examined() -> void:
	var c: Control = screens["examine"]
	var art: TextureRect = c.get_child(0).get_node("Art")
	# an item the sampler leaves out has no picture: the key it does have stands in
	art.texture = icon_texture(selected, true) if icon_texture(selected, true) else icon_texture("key_skeleton", true)
	var text: Control = c.get_child(1).get_child(0)
	(text.get_node("Name") as Label).text = ITEMS[selected][0]
	(text.get_node("Text") as Label).text = ITEMS[selected][1]


func _map(c: Control) -> void:
	var head := row(c, 6)
	label(head, "1F", &"Headline")
	label(head, "East Wing", &"Heading").size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var screen_ := panel(c, &"MonitorPanel", Vector2(0, 26))
	var plan := Control.new()
	plan.custom_minimum_size = Vector2(36, 19) * UNIT
	screen_.add_child(plan)
	for r in ROOMS:
		var room := Panel.new()
		room.theme_type_variation = StringName(r[4])
		room.position = Vector2(r[0], r[1]) * UNIT
		room.size = Vector2(r[2], r[3]) * UNIT
		room.tooltip_text = r[5]
		plan.add_child(room)
	for m in MARKS:
		var mark := Mark.new(m[0])
		plan.add_child(mark)
		mark.position = (Vector2(m[1], m[2]) * UNIT - mark.get_combined_minimum_size() / 2).floor()
	var legend := window(c, "Legend", Vector2(262, 26), 80)
	legend.add_theme_constant_override("separation", 1)
	for pair in [[&"you", "You"], [&"save", "Safe room"], [&"item", "Item"], [&"door", "Door"], [&"door_locked", "Locked"]]:
		var r := row(legend, 4)
		var mark := Mark.new(pair[0])
		mark.custom_minimum_size.x = 10
		mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(mark)
		label(r, pair[1])
	for pair in [[&"MapRoomCurrent", "Here"], [&"MapRoomItems", "Items"], [&"MapRoomUnknown", "Unseen"]]:
		var r := row(legend, 4)
		var room := Panel.new()
		room.theme_type_variation = pair[0]
		room.custom_minimum_size = Vector2(10, 10)
		room.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(room)
		label(r, pair[1])
	label(c, "Point at a room for its name", &"Hint").position = Vector2(0, 176)


func _files(c: Control) -> void:
	var list := window(c, "Files", Vector2.ZERO, 88)
	list.add_theme_constant_override("separation", 0)
	var page := panel(c, &"DocumentPanel", Vector2(94, 0))
	page.custom_minimum_size = Vector2(248, 214)
	var text := column(page, 6)
	var title := label(text, "", &"Ink")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var body := label(text, "", &"Ink", 230)
	var group := ButtonGroup.new()
	for f in FILES:
		menu_item(list, f, group).toggled.connect(func(on: bool) -> void:
			if on:
				title.text = f.to_upper()
				body.text = FILES[f])
	(list.get_child(1) as Button).button_pressed = true


func _save(c: Control) -> void:
	var left := column(c, 4)
	var view := panel(left, &"ExaminePanel")
	view.custom_minimum_size = Vector2(150, 112)
	var art := icon("typewriter", true)
	if art.texture == null:
		art.texture = icon_texture("ink_ribbon", true)
	view.add_child(art)
	var ask := panel(left, &"DialoguePanel")
	var text := column(ask, 1)
	label(text, "Will you use an ink ribbon to record your progress?", &"", 128)
	var answer := row(text, 8)
	for t in ["Yes", "No"]:
		menu_item(answer, t).custom_minimum_size.x = 40
	var list := window(c, "Save", Vector2(156, 0), 186)
	var group := ButtonGroup.new()
	var saves := [["Main Hall", "02:14:36", 4], ["Safe Room", "01:40:02", 3], ["Greenhouse", "00:52:17", 2], []]
	for i in saves.size():
		var b := Button.new()
		b.theme_type_variation = &"SaveSlot"
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.button_group = group
		var s: Array = saves[i]
		b.text = ("No.%d  %s\n      %s  Saves %d" % [i + 1, s[0], s[1], s[2]]) if not s.is_empty() else "No.%d  NO DATA\n " % [i + 1]
		b.button_pressed = i == 0
		list.add_child(b)
	var ribbons := row(list, 6)
	slot(ribbons, "ink_ribbon", 3)
	label(ribbons, "Ink ribbons: 3", &"Hint").size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _options(c: Control) -> void:
	var pause := window(c, "Paused", Vector2.ZERO, 92)
	pause.add_theme_constant_override("separation", 0)
	var group := ButtonGroup.new()
	for t in ["Resume", "Options", "Load game", "Quit to title"]:
		menu_item(pause, t, group).button_pressed = t == "Options"
	var box := window(c, "Options", Vector2(98, 0), 244)
	var tabs := TabContainer.new()
	box.add_child(tabs)
	var sound := column(tabs, 3)
	sound.name = "Sound"
	for pair in [["Music", 60], ["Effects", 80], ["Voices", 70]]:
		var r := row(sound)
		label(r, pair[0]).custom_minimum_size.x = 48
		var s := HSlider.new()
		s.value = pair[1]
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(s)
	var output := OptionButton.new()
	for o in ["Stereo", "Mono", "Headphones"]:
		output.add_item(o)
	sound.add_child(output)
	var display := column(tabs, 3)
	display.name = "Display"
	var r := row(display)
	label(r, "Brightness").custom_minimum_size.x = 60
	bar(r, "fine", 55).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for t in ["Subtitles", "Screen shake", "Film grain"]:
		var cb := CheckBox.new()
		cb.text = t
		cb.button_pressed = t != "Screen shake"
		display.add_child(cb)
	var controls := column(tabs, 3)
	controls.name = "Controls"
	var modes := ButtonGroup.new()
	for t in ["Tank controls", "Modern controls"]:
		var radio := CheckBox.new()
		radio.text = t
		radio.button_group = modes
		radio.button_pressed = t.begins_with("Tank")
		controls.add_child(radio)
	var name_field := LineEdit.new()
	name_field.placeholder_text = "Profile name"
	controls.add_child(name_field)
	box.add_child(HSeparator.new())
	var buttons := row(box)
	for t in ["Back", "Apply"]:
		var b := Button.new()
		b.text = t
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buttons.add_child(b)


## The heart monitor, its reading and optionally a bar; a click moves it on to the next condition.
class Condition extends VBoxContainer:
	var state := "fine":
		set(v):
			state = v
			if is_node_ready():
				_show()
	var with_bar := false
	var ecg := Ecg.new()
	var reading := Label.new()
	var fill: ProgressBar

	func _ready() -> void:
		add_theme_constant_override("separation", 2)
		var screen := PanelContainer.new()
		screen.theme_type_variation = &"MonitorPanel"
		screen.tooltip_text = "Click to change the condition"
		add_child(screen)
		screen.add_child(ecg)
		screen.gui_input.connect(func(e: InputEvent) -> void:
			if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				state = CONDITIONS[(CONDITIONS.find(state) + 1) % CONDITIONS.size()])
		add_child(reading)
		if with_bar:
			fill = ProgressBar.new()
			fill.show_percentage = false
			fill.custom_minimum_size.y = 10
			add_child(fill)
		_show()

	func _show() -> void:
		ecg.state = state
		reading.text = state.capitalize()
		reading.theme_type_variation = StringName(state.capitalize())
		if fill:
			fill.theme_type_variation = StringName(state.capitalize() + "Bar")
			fill.value = {"fine": 90, "caution": 55, "danger": 20, "poison": 45}[state]


## An ECG trace scrolling left, faster the worse the condition.
class Ecg extends Control:
	const SPEED := {"fine": 24.0, "caution": 36.0, "danger": 56.0, "poison": 30.0}
	var state := "fine":
		set(v):
			state = v
			# loaded here, not in _draw: a texture first loaded while drawing draws blank white
			trace = load(KIT + "status/ecg_%s.png" % v)
	var trace: Texture2D = load(KIT + "status/ecg_fine.png")
	var shift := 0.0

	func _init() -> void:
		custom_minimum_size = Vector2(74, 16)
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		shift = fmod(shift + delta * SPEED[state], 64.0)
		queue_redraw()

	func _draw() -> void:
		for i in ceili(size.x / 64.0) + 1:
			draw_texture(trace, Vector2(i * 64 - floorf(shift), 0))


## One of the theme's map marks or arrows (get_theme_icon(name, "Marks")), optionally blinking.
class Mark extends Control:
	var mark: StringName
	var blink := false

	func _init(m: StringName) -> void:
		mark = m
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _get_minimum_size() -> Vector2:
		return get_theme_icon(mark, &"Marks").get_size()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_THEME_CHANGED:
			update_minimum_size()
			queue_redraw()

	func _process(_delta: float) -> void:
		if blink:
			queue_redraw()

	func _draw() -> void:
		if not blink or Engine.get_process_frames() / 20 % 2 == 0:
			draw_texture(get_theme_icon(mark, &"Marks"), Vector2.ZERO)


## A dark, dithered room behind the UI, drawn at half the art's resolution like a PS1 backdrop.
class Backdrop extends TextureRect:
	const DITHER := [[-4, 0, -3, 1], [2, -2, 3, -1], [-3, 1, -4, 0], [3, -1, 2, -2]]

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		show_behind_parent = true
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stretch_mode = TextureRect.STRETCH_SCALE
		var w := 320
		var h := 180
		var img := Image.create(w, h, false, Image.FORMAT_RGB8)
		for y in h:
			for x in w:
				# a corridor: walls lit from the far end, the floor and ceiling falling away to black
				var dx := absf(x - w * 0.5) / (w * 0.5)
				var dy := absf(y - h * 0.46) / (h * 0.5)
				var glow := clampf(1.0 - maxf(dx, dy * 1.4), 0.0, 1.0)
				var v := 10.0 + 34.0 * glow * glow
				if absf(dx - dy * 1.6) < 0.012 or (dy > 0.3 and int(dy * 40) % 5 == 0 and y > h / 2):
					v *= 1.4
				var d: int = DITHER[y % 4][x % 4]
				var c := Color8(_q(v * 0.8 + d), _q(v * 0.95 + d), _q(v + d))
				img.set_pixel(x, y, c)
		texture = ImageTexture.create_from_image(img)

	static func _q(v: float) -> int:
		var i := clampi(roundi(v), 0, 255)
		return (i >> 3) << 3 | i >> 5
