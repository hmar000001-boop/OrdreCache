extends Node3D

## Scene coordinator. World, rules, save handling and localization are separated from HUD/session flow.
const Catalog = preload("res://scripts/puzzle_catalog.gd")
const PuzzleEngineScript = preload("res://scripts/puzzle_engine.gd")
const GardenWorldScript = preload("res://scripts/garden_world.gd")
const Localization = preload("res://scripts/localization.gd")
const SaveServiceScript = preload("res://scripts/save_service.gd")
const SOUND_SELECT = preload("res://assets/audio/symbol_select.wav")
const SOUND_DISCOVERY = preload("res://assets/audio/law_discovery.wav")
const SOUND_NO_CHANGE = preload("res://assets/audio/no_change.wav")

const SYMBOL_GLYPHS: Dictionary = {"sun": "☼", "rain": "≋", "moon": "☾", "wind": "≈"}

var engine: Variant = PuzzleEngineScript.new()
var save_service: Variant = SaveServiceScript.new()
var garden: Variant
var canvas: CanvasLayer
var sfx_player: AudioStreamPlayer
var ui_root: Control
var lang := "fr"
var screen := "home"
var previous_screen := "home"
var puzzle_index := 0
var selected_symbol := "sun"
var status_kind := ""
var status_law_id := ""
var hint_visible := false
var object_inspected := false
var completed := false

# Stable gameplay HUD references: routine interactions update these controls in place.
var game_progress_label: Label
var game_laws_label: Label
var game_object_label: Label
var game_status_label: Label
var game_footer_label: Label
var game_symbol_buttons: Dictionary = {}
var game_apply_button: Button
var game_next_button: Button
var game_hint_button: Button
var game_hint_panel: PanelContainer
var game_hint_label: Label

func _ready() -> void:
	name = "LOrdreCacheGame"
	garden = GardenWorldScript.new()
	garden.name = "GardenWorld"
	add_child(garden)
	garden.target_selected.connect(_on_target_selected)
	garden.symbol_selected.connect(_on_world_symbol_selected)
	canvas = CanvasLayer.new()
	canvas.name = "GameInterface"
	add_child(canvas)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SoundEffects"
	sfx_player.volume_db = -6.0
	add_child(sfx_player)
	ui_root = Control.new()
	ui_root.name = "UIRoot"
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui_root)
	_load_save()
	garden.set_object_state(engine.state)
	garden.set_selected_symbol(selected_symbol)
	_draw_ui()

func _unhandled_input(event: InputEvent) -> void:
	if screen == "game" and object_inspected:
		if event is InputEventScreenDrag:
			garden.rotate_target_object(event.relative)
			return
		if event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			garden.rotate_target_object(event.relative)
			return
	var tap_position := Vector2.ZERO
	var pressed := false
	if event is InputEventScreenTouch and event.pressed:
		tap_position = event.position
		pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tap_position = event.position
		pressed = true
	if not pressed or screen in ["home", "notebook", "finish"]:
		return
	if not is_instance_valid(garden):
		return
	var active_camera: Camera3D = garden.camera
	if active_camera == null:
		return
	var ray_origin := active_camera.project_ray_origin(tap_position)
	var ray_end := ray_origin + active_camera.project_ray_normal(tap_position) * 100.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider = hit.get("collider")
	if collider is Node and (collider as Node).has_meta("interaction_id"):
		garden.activate_interaction(str((collider as Node).get_meta("interaction_id")))

func _load_save() -> void:
	var saved: Dictionary = save_service.load_snapshot()
	lang = str(saved["language"])
	puzzle_index = int(saved["puzzle_index"])
	var restored_laws: Array[String] = []
	var saved_laws: Variant = saved.get("discovered", [])
	if saved_laws is Array:
		for law_id in saved_laws:
			if law_id is String:
				restored_laws.append(law_id)
	engine.restore(str(saved["object_state"]), restored_laws)
	selected_symbol = str(saved["selected_symbol"])
	completed = bool(saved["completed"])
	status_kind = "solved" if bool(saved["status_success"]) else ""
	status_law_id = ""

func _save() -> void:
	var snapshot := {
		"language": lang,
		"puzzle_index": puzzle_index,
		"discovered": engine.discovered,
		"completed": completed,
		"object_state": engine.state,
		"status_success": status_kind == "solved" or (engine.state == str(Catalog.PUZZLES[puzzle_index]["goal"]) and completed),
		"selected_symbol": selected_symbol
	}
	if not save_service.save_snapshot(snapshot):
		push_warning("Could not save local progress.")

func _t(key: String) -> String:
	var dictionary: Dictionary = Localization.TEXT.get(lang, Localization.TEXT["fr"])
	return str(dictionary.get(key, Localization.TEXT["fr"].get(key, key)))

func _draw_ui() -> void:
	# Full HUD reconstruction is reserved for screen/language changes, never world actions.
	for child in ui_root.get_children():
		ui_root.remove_child(child)
		child.queue_free()
	_reset_game_ui_refs()
	ui_root.layout_direction = Control.LAYOUT_DIRECTION_RTL if lang == "ar" else Control.LAYOUT_DIRECTION_LTR
	_build_header()
	match screen:
		"home": _build_home()
		"notebook": _build_notebook()
		"finish": _build_finish()
		_: _build_game()

func _reset_game_ui_refs() -> void:
	game_progress_label = null
	game_laws_label = null
	game_object_label = null
	game_status_label = null
	game_footer_label = null
	game_symbol_buttons.clear()
	game_apply_button = null
	game_next_button = null
	game_hint_button = null
	game_hint_panel = null
	game_hint_label = null

func _build_header() -> void:
	var panel := _panel("Header", 12.0, 12.0, -12.0, 108.0, 0.91)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var brand_col := VBoxContainer.new()
	brand_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand_col.add_child(_label(_t("brand"), 18, Color("d7f2e2"), true))
	brand_col.add_child(_label(_t("chapter") if screen != "home" else _t("tagline"), 9, Color("a5c2b8")))
	row.add_child(brand_col)
	var language := OptionButton.new()
	language.custom_minimum_size = Vector2(78, 42)
	language.add_theme_font_size_override("font_size", 13)
	language.add_item("FR", 0)
	language.add_item("EN", 1)
	language.add_item("عربي", 2)
	language.select(["fr", "en", "ar"].find(lang))
	language.item_selected.connect(_on_language_selected)
	row.add_child(language)
	if screen in ["game", "notebook", "finish"]:
		var home_button := _button("⌂", _go_home, false)
		home_button.custom_minimum_size = Vector2(42, 42)
		row.add_child(home_button)

func _build_home() -> void:
	var card := _panel("WelcomeCard", 22.0, 0.27, -22.0, 0.73, 0.91, true)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	card.add_child(content)
	content.add_child(_label(_t("home_kicker"), 10, Color("9ce3c6"), true, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label("✦", 50, Color("b9e8d2"), true, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label(_t("home_title"), 29, Color("f0f5e8"), true, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label(_t("home_intro"), 15, Color("c2d6cc"), false, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label(_t("home_note"), 11, Color("9abdb1"), false, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_button(_t("continue") if puzzle_index > 0 or completed else _t("start"), _start_game, true))
	content.add_child(_button(_t("notebook"), _open_notebook, false))

func _build_game() -> void:
	var puzzle: Dictionary = Catalog.PUZZLES[puzzle_index]
	var panel := _panel("InteractionPanel", 12.0, 0.52, -12.0, -12.0, 0.94, false)
	var scroller := ScrollContainer.new()
	scroller.name = "InteractionScroll"
	scroller.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroller)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 7)
	scroller.add_child(content)

	var progress := HBoxContainer.new()
	game_progress_label = _label("", 10, Color("a3e5c9"), true)
	progress.add_child(game_progress_label)
	var flex := Control.new()
	flex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress.add_child(flex)
	game_laws_label = _label("", 10, Color("a3e5c9"), true)
	progress.add_child(game_laws_label)
	content.add_child(progress)
	content.add_child(_label(_t(str(puzzle["title"])), 21, Color("f0f5e8"), true))
	content.add_child(_label(_t(str(puzzle["desc"])), 12, Color("c1d4cc")))
	game_object_label = _label("", 11, Color("9ce3c6"), true)
	content.add_child(game_object_label)
	var status_panel := _panel("Status", 0.0, 0.0, 0.0, 0.0, 0.88, false, content)
	game_status_label = _label("", 12, Color("d8efdf"))
	status_panel.add_child(game_status_label)

	var symbols := GridContainer.new()
	symbols.columns = 2
	symbols.add_theme_constant_override("h_separation", 8)
	symbols.add_theme_constant_override("v_separation", 6)
	content.add_child(symbols)
	for symbol in Catalog.SYMBOLS:
		var callback := Callable(self, "_select_symbol").bind(symbol)
		var button := _button(_symbol_label(symbol), callback, selected_symbol == symbol)
		button.custom_minimum_size.y = 39
		symbols.add_child(button)
		game_symbol_buttons[symbol] = button

	game_apply_button = _button(_t("apply"), _observe, true)
	content.add_child(game_apply_button)
	game_next_button = _button("", _advance, true)
	content.add_child(game_next_button)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	game_hint_button = _button("", _toggle_hint, false)
	actions.add_child(game_hint_button)
	actions.add_child(_button(_t("reset"), _reset_trial, false))
	content.add_child(actions)
	game_hint_panel = _panel("Hint", 0.0, 0.0, 0.0, 0.0, 0.82, false, content)
	game_hint_label = _label("", 12, Color("d2dfd6"))
	game_hint_panel.add_child(game_hint_label)
	game_footer_label = _label("", 10, Color("87aaa0"))
	content.add_child(game_footer_label)
	content.add_child(_button(_t("notebook"), _open_notebook, false))
	_refresh_game_ui()

func _refresh_game_ui() -> void:
	if screen != "game" or not is_instance_valid(game_status_label):
		return
	var puzzle: Dictionary = Catalog.PUZZLES[puzzle_index]
	var solved: bool = status_kind == "solved" or (str(engine.state) == str(puzzle["goal"]) and completed)
	game_progress_label.text = "%02d / %02d" % [puzzle_index + 1, Catalog.PUZZLES.size()]
	game_laws_label.text = "✦ %d / %d" % [engine.discovered.size(), Catalog.KNOWN_LAWS.size()]
	game_object_label.text = _t("object") + " · " + _t(engine.state)
	game_status_label.text = _current_status_text()
	game_footer_label.text = _t("tap_object") if not object_inspected else _t("drag_object")
	game_apply_button.visible = not solved
	game_next_button.visible = solved
	game_next_button.text = _t("next") if puzzle_index < Catalog.PUZZLES.size() - 1 else _t("finish_title")
	game_hint_button.text = _t("hide_hint") if hint_visible else _t("hint")
	game_hint_panel.visible = hint_visible
	game_hint_label.text = _t(str(puzzle["hint"]))
	for symbol_id in game_symbol_buttons:
		var button: Button = game_symbol_buttons[symbol_id]
		_set_button_appearance(button, symbol_id == selected_symbol)

func _build_notebook() -> void:
	var card := _panel("NotebookCard", 18.0, 0.145, -18.0, -18.0, 0.96, false)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	card.add_child(outer)
	outer.add_child(_label(_t("notebook"), 23, Color("eff7e9"), true))
	outer.add_child(_label("%d / %d %s" % [engine.discovered.size(), Catalog.KNOWN_LAWS.size(), _t("laws")], 12, Color("a7d0bf")))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	if engine.discovered.is_empty():
		list.add_child(_label(_t("notebook_empty"), 14, Color("c5d7ce")))
	else:
		for law_id in engine.discovered:
			var law_panel := _panel("DiscoveredLaw", 0.0, 0.0, 0.0, 0.0, 0.88, false, list)
			law_panel.add_child(_label("✦  " + _t("observed"), 9, Color("92d9b8"), true))
			law_panel.add_child(_label(_t(law_id), 15, Color("e2eee1")))
	outer.add_child(_button(_t("back"), _back_from_notebook, true))
	outer.add_child(_button(_t("home"), _go_home, false))

func _build_finish() -> void:
	var card := _panel("FinishCard", 22.0, 0.27, -22.0, 0.75, 0.95, true)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 13)
	card.add_child(content)
	content.add_child(_label("✧  ✦  ✧", 35, Color("b6e4cf"), true, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label(_t("finish_title"), 25, Color("edf6e8"), true, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label(_t("finish_desc"), 14, Color("c1d6ce"), false, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label("%d / %d · %s" % [engine.discovered.size(), Catalog.KNOWN_LAWS.size(), _t("progress")], 12, Color("9cc7b6"), false, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_button(_t("replay"), _replay, true))
	content.add_child(_button(_t("notebook"), _open_notebook, false))
	content.add_child(_button(_t("home"), _go_home, false))

func _panel(panel_name: String, left: float, top: float, right: float, bottom: float, alpha: float = 0.92, centered: bool = false, parent: Control = null) -> PanelContainer:
	var p := PanelContainer.new()
	p.name = panel_name
	p.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.075, 0.09, alpha), Color("4a746b")))
	if parent != null:
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		parent.add_child(p)
	else:
		ui_root.add_child(p)
		if centered:
			p.anchor_left = 0.07
			p.anchor_right = 0.93
			p.anchor_top = top
			p.anchor_bottom = bottom
			p.offset_left = 0.0
			p.offset_right = 0.0
			p.offset_top = 0.0
			p.offset_bottom = 0.0
		else:
			p.anchor_left = 0.0
			p.anchor_right = 1.0
			p.offset_left = left
			p.offset_right = right
			if top > 1.0 or bottom > 1.0:
				# Fixed top/bottom pixel offsets (for the HUD header).
				p.anchor_top = 0.0
				p.anchor_bottom = 0.0
				p.offset_top = top
				p.offset_bottom = bottom
			elif bottom < 0.0:
				# A top anchor plus a bottom inset (game panel/notebook).
				p.anchor_top = top
				p.anchor_bottom = 1.0
				p.offset_top = 0.0
				p.offset_bottom = bottom
			else:
				p.anchor_top = top
				p.anchor_bottom = bottom
				p.offset_top = 0.0
				p.offset_bottom = 0.0
	return p

func _panel_style(color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style

func _label(value: String, font_size: int = 14, color: Color = Color("e2ece7"), bold: bool = false, alignment: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if bold:
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.22))
	return label

func _button(value: String, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(0.0, 42.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	_set_button_appearance(button, primary)
	button.pressed.connect(callback)
	return button

func _set_button_appearance(button: Button, primary: bool) -> void:
	var normal_color := Color("b6e4cf") if primary else Color("142a32")
	var border_color := Color("c3edda") if primary else Color("3d625e")
	button.add_theme_stylebox_override("normal", _button_style(normal_color, border_color))
	button.add_theme_stylebox_override("hover", _button_style(normal_color.lightened(0.10), border_color.lightened(0.16)))
	button.add_theme_stylebox_override("pressed", _button_style(normal_color.darkened(0.08), border_color))
	button.add_theme_stylebox_override("focus", _button_style(normal_color, border_color))
	button.add_theme_color_override("font_color", Color("0b1c20") if primary else Color("e2ece7"))
	button.add_theme_color_override("font_hover_color", Color("071417") if primary else Color("ffffff"))

func _button_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := _panel_style(background, border)
	style.set_corner_radius_all(11)
	style.content_margin_left = 9.0
	style.content_margin_right = 9.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	return style

func _symbol_label(symbol_id: String) -> String:
	return "%s   %s" % [str(SYMBOL_GLYPHS.get(symbol_id, "✦")), _t(symbol_id)]

func _play_sound(sound_id: String) -> void:
	if not is_instance_valid(sfx_player):
		return
	match sound_id:
		"select": sfx_player.stream = SOUND_SELECT
		"discovery": sfx_player.stream = SOUND_DISCOVERY
		"no_change": sfx_player.stream = SOUND_NO_CHANGE
		_: return
	sfx_player.play()

func _current_status_text() -> String:
	if status_kind.is_empty():
		return _t("experiment")
	var result := ""
	match status_kind:
		"no_change": result = _t("no_change")
		"inspected": result = _t("inspected") + " — " + _t(engine.state)
		"symbol_selected": result = _t("selected") + " : " + _t(selected_symbol)
		"law_found": result = _t("law_found") + " — " + _t(status_law_id)
		"law_known": result = _t("law_known")
		"changed": result = _t("result")
		"solved": result = _t("solved") + (" — " + _t(status_law_id) if not status_law_id.is_empty() else "")
		_: result = _t("experiment")
	return result

func _on_target_selected() -> void:
	object_inspected = true
	if status_kind != "solved":
		status_kind = "inspected"
		status_law_id = ""
	_refresh_game_ui()

func _on_world_symbol_selected(symbol_id: String) -> void:
	if Catalog.SYMBOLS.has(symbol_id):
		_select_symbol(symbol_id)

func _select_symbol(symbol_id: String) -> void:
	if status_kind == "solved":
		return
	if not Catalog.SYMBOLS.has(symbol_id):
		return
	selected_symbol = symbol_id
	garden.set_selected_symbol(selected_symbol)
	_play_sound("select")
	status_kind = "symbol_selected"
	status_law_id = ""
	_save()
	_refresh_game_ui()

func _observe() -> void:
	if screen != "game" or status_kind == "solved":
		return
	var outcome: Dictionary = engine.observe(selected_symbol, puzzle_index)
	garden.set_object_state(engine.state)
	if not bool(outcome["changed"]):
		status_kind = "no_change"
		status_law_id = ""
		_play_sound("no_change")
	else:
		if bool(outcome["new_law"]):
			_play_sound("discovery")
		status_law_id = str(outcome["law_id"])
		if bool(outcome["solved"]):
			status_kind = "solved"
			if puzzle_index == Catalog.PUZZLES.size() - 1:
				completed = true
		elif bool(outcome["new_law"]):
			status_kind = "law_found"
		else:
			status_kind = "changed" if status_law_id.is_empty() else "law_known"
	_save()
	_refresh_game_ui()

func _advance() -> void:
	if screen != "game" or status_kind != "solved":
		return
	if puzzle_index < Catalog.PUZZLES.size() - 1:
		puzzle_index += 1
		engine.begin_puzzle(puzzle_index)
		selected_symbol = str(Catalog.PUZZLES[puzzle_index]["first"])
		status_kind = ""
		status_law_id = ""
		hint_visible = false
		object_inspected = false
		garden.set_object_state(engine.state)
		garden.set_selected_symbol(selected_symbol)
		screen = "game"
	else:
		screen = "finish"
		status_kind = ""
	_save()
	_draw_ui()

func _toggle_hint() -> void:
	hint_visible = not hint_visible
	_refresh_game_ui()

func _reset_trial() -> void:
	engine.begin_puzzle(puzzle_index)
	status_kind = ""
	status_law_id = ""
	hint_visible = false
	object_inspected = false
	completed = false if puzzle_index == Catalog.PUZZLES.size() - 1 else completed
	garden.set_object_state(engine.state)
	_save()
	_refresh_game_ui()

func _open_notebook() -> void:
	if screen != "notebook":
		previous_screen = screen
	screen = "notebook"
	_draw_ui()

func _back_from_notebook() -> void:
	screen = previous_screen if previous_screen in ["home", "game", "finish"] else "home"
	_draw_ui()

func _start_game() -> void:
	screen = "finish" if completed else "game"
	_draw_ui()

func _go_home() -> void:
	screen = "home"
	_draw_ui()

func _replay() -> void:
	puzzle_index = 0
	engine.begin_puzzle(0)
	selected_symbol = "sun"
	status_kind = ""
	status_law_id = ""
	hint_visible = false
	object_inspected = false
	completed = false
	screen = "game"
	garden.set_object_state(engine.state)
	garden.set_selected_symbol(selected_symbol)
	_save()
	_draw_ui()

func _on_language_selected(index: int) -> void:
	var options: Array[String] = ["fr", "en", "ar"]
	if index >= 0 and index < options.size():
		lang = options[index]
		_save()
		_draw_ui()
