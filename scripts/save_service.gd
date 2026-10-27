extends RefCounted

## Local/offline persistence with schema and domain validation independent of the UI.
const Catalog = preload("res://scripts/puzzle_catalog.gd")
const Localization = preload("res://scripts/localization.gd")
const SAVE_PATH := "user://ordre_cache_save.cfg"
const SAVE_VERSION := 2

func load_snapshot() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return sanitize_snapshot({})
	return sanitize_snapshot({
		"save_version": cfg.get_value("meta", "save_version", 1),
		"language": cfg.get_value("settings", "language", "fr"),
		"puzzle_index": cfg.get_value("progress", "puzzle_index", 0),
		"discovered": cfg.get_value("progress", "discovered", []),
		"object_state": cfg.get_value("progress", "object_state", "seed"),
		"selected_symbol": cfg.get_value("progress", "selected_symbol", "sun"),
		"completed": cfg.get_value("progress", "completed", false),
		"status_success": cfg.get_value("progress", "status_success", false)
	})

func save_snapshot(snapshot: Dictionary) -> bool:
	var clean := sanitize_snapshot(snapshot)
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "save_version", SAVE_VERSION)
	cfg.set_value("settings", "language", clean["language"])
	cfg.set_value("progress", "puzzle_index", clean["puzzle_index"])
	cfg.set_value("progress", "discovered", clean["discovered"])
	cfg.set_value("progress", "object_state", clean["object_state"])
	cfg.set_value("progress", "selected_symbol", clean["selected_symbol"])
	cfg.set_value("progress", "completed", clean["completed"])
	cfg.set_value("progress", "status_success", clean["status_success"])
	return cfg.save(SAVE_PATH) == OK

## Static for regression tests; accepts untrusted save values and returns a safe canonical snapshot.
static func sanitize_snapshot(raw: Dictionary) -> Dictionary:
	var empty_discovered: Array[String] = []
	var result: Dictionary = {
		"save_version": SAVE_VERSION,
		"language": "fr",
		"puzzle_index": 0,
		"discovered": empty_discovered,
		"object_state": "seed",
		"selected_symbol": "sun",
		"completed": false,
		"status_success": false
	}

	var candidate_language := str(raw.get("language", "fr"))
	if Localization.TEXT.has(candidate_language):
		result["language"] = candidate_language

	var incoming_version := int(raw.get("save_version", 1))
	if incoming_version > SAVE_VERSION:
		# Preserve a recognized language setting, but do not trust newer gameplay data.
		return result

	var requested_index := int(raw.get("puzzle_index", 0))
	var puzzle_index := clampi(requested_index, 0, Catalog.PUZZLES.size() - 1)
	result["puzzle_index"] = puzzle_index
	var puzzle: Dictionary = Catalog.PUZZLES[puzzle_index]
	var start_state := str(puzzle["start"])
	var candidate_state := str(raw.get("object_state", start_state))
	if not Catalog.valid_state_for_puzzle(candidate_state, puzzle_index):
		candidate_state = start_state
	result["object_state"] = candidate_state

	var selected := str(raw.get("selected_symbol", str(puzzle["first"])))
	if not Catalog.SYMBOLS.has(selected):
		selected = str(puzzle["first"])
	result["selected_symbol"] = selected

	var discovered: Array[String] = []
	var raw_discovered: Variant = raw.get("discovered", [])
	if raw_discovered is Array:
		for item in raw_discovered:
			if item is String and Catalog.KNOWN_LAWS.has(item) and not discovered.has(item):
				discovered.append(item)
	result["discovered"] = discovered

	var is_last_puzzle := puzzle_index == Catalog.PUZZLES.size() - 1
	var is_goal_state := candidate_state == str(puzzle["goal"])
	result["completed"] = bool(raw.get("completed", false)) and is_last_puzzle and is_goal_state
	result["status_success"] = bool(raw.get("status_success", false)) and is_goal_state
	return result
