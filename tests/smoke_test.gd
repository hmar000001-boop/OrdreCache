extends SceneTree

const Catalog = preload("res://scripts/puzzle_catalog.gd")
const PuzzleEngine = preload("res://scripts/puzzle_engine.gd")
const SaveService = preload("res://scripts/save_service.gd")

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _run() -> void:
	print("SMOKE_TEST_START: validate 3D scene and game rules")
	_test_puzzle_engine()
	await _test_scene_and_navigation()
	_finish()

func _test_puzzle_engine() -> void:
	var rules: Variant = PuzzleEngine.new()
	rules.begin_puzzle(0)
	var first: Dictionary = rules.observe("sun", 0)
	_check(bool(first["changed"]) and rules.state == "sprout", "Sun wakes the seed")
	_check(bool(first["solved"]), "Puzzle 1 goal is detected")
	_check(bool(first["new_law"]) and rules.discovered.has("rule_sun"), "Newly observed law is recorded")
	var wrong: Dictionary = rules.observe("moon", 1)
	_check(not bool(wrong["changed"]) and rules.state == "sprout", "Invalid transition leaves state unchanged")

	rules.begin_puzzle(4)
	var sun: Dictionary = rules.observe("sun", 4)
	_check(rules.state == "stone_warm" and str(sun["law_id"]) == "rule_stone_sun", "Sun warms the stone and records its own law")
	var moon: Dictionary = rules.observe("moon", 4)
	_check(rules.state == "stone_marked" and str(moon["law_id"]) == "rule_stone_moon", "Moon reveals the mark and records its own law")
	var wind: Dictionary = rules.observe("wind", 4)
	_check(rules.state == "stone_open" and bool(wind["solved"]), "Wind opens the marked stone")
	_check(str(wind["law_id"]) == "rule_stone_wind" and rules.discovered.has("rule_stone_wind"), "Final stone law is discovered at the correct transition")
	_check(rules.discovered.has("rule_stone_sun") and rules.discovered.has("rule_stone_moon"), "Earlier stone laws remain recorded without a special-case award")

	rules.begin_puzzle(5)
	var final_sun: Dictionary = rules.observe("sun", 5)
	_check(bool(final_sun["changed"]) and rules.state == "sprout", "Final puzzle begins by waking the seed")
	var final_rain: Dictionary = rules.observe("rain", 5)
	_check(bool(final_rain["changed"]) and rules.state == "sapling", "Rain advances the sprout during the final sequence")
	var final_moon: Dictionary = rules.observe("moon", 5)
	_check(rules.state == "bloom" and bool(final_moon["solved"]), "Final puzzle combines the previously learned sequence")
	var invalid: Dictionary = rules.observe("unknown", 5)
	_check(not bool(invalid["changed"]), "Unknown symbols are rejected safely")
	_check(Catalog.valid_state_for_puzzle("stone_marked", 4), "Save validation accepts a valid intermediate stone state")
	_check(not Catalog.valid_state_for_puzzle("bloom", 4), "Save validation rejects a state from another puzzle family")
	_check(Catalog.valid_state_for_puzzle("carried", 0), "Save validation preserves a reachable but unsuccessful experiment")

	var sanitized: Dictionary = SaveService.sanitize_snapshot({
		"save_version": 2,
		"language": "xx",
		"puzzle_index": 4,
		"object_state": "bloom",
		"selected_symbol": "invalid",
		"discovered": ["rule_sun", "not_a_law", "rule_sun"],
		"completed": true,
		"status_success": true
	})
	_check(str(sanitized["language"]) == "fr", "Save service falls back from an unsupported language")
	_check(int(sanitized["puzzle_index"]) == 4 and str(sanitized["object_state"]) == "stone_cold", "Save service rejects a state belonging to another puzzle")
	_check(str(sanitized["selected_symbol"]) == "sun", "Save service replaces an invalid symbol with the puzzle default")
	var cleaned_laws: Variant = sanitized["discovered"]
	_check(cleaned_laws is Array and cleaned_laws.size() == 1, "Save service filters unknown and duplicate discovered laws")
	_check(not bool(sanitized["completed"]) and not bool(sanitized["status_success"]), "Save service rejects completion flags inconsistent with the puzzle state")
	var future_save: Dictionary = SaveService.sanitize_snapshot({"save_version": 999, "language": "en", "object_state": "stone_open", "puzzle_index": 4})
	_check(str(future_save["language"]) == "en" and int(future_save["puzzle_index"]) == 0, "Future save versions preserve valid settings but reset unknown progress")

func _test_scene_and_navigation() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	_check(packed != null, "Main 3D scene resource loads")
	if packed == null:
		return
	var instance: Variant = packed.instantiate()
	_check(instance is Node3D, "Main scene root is Node3D")
	if instance == null:
		return
	root.add_child(instance)
	await process_frame
	await process_frame
	_check(instance.get_node_or_null("GardenWorld") != null, "Procedural garden world is present")
	_check(instance.get_node_or_null("GameInterface") != null, "HUD is separated into a CanvasLayer")
	_check(instance.garden != null and instance.garden.camera != null, "Garden has an active 3D camera")
	_check(instance.garden.symbol_areas.size() == 4, "Four world-space sign pedestals are interactive")
	_check(instance.garden.target_area != null, "Central mystery object has a collision target")
	_check(instance.garden.camera.current, "Garden camera is active")
	for symbol_id in Catalog.SYMBOLS:
		var sign_area: Area3D = instance.garden.symbol_areas[symbol_id]
		_check(sign_area.input_ray_pickable and sign_area.has_meta("interaction_id"), "Sign %s is available to ray picking" % symbol_id)
		_check(sign_area.get_node_or_null("SymbolCap") is MeshInstance3D, "Sign %s has a named visual cap for selection feedback" % symbol_id)
		var horizontal_angle: float = absf(atan2(sign_area.global_position.x, absf(sign_area.global_position.z - instance.garden.camera.global_position.z)))
		_check(horizontal_angle < deg_to_rad(9.0), "Sign %s is kept inside the portrait camera safe area" % symbol_id)

	instance.screen = "home"
	instance._open_notebook()
	_check(instance.screen == "notebook", "Notebook opens from the home screen")
	instance._back_from_notebook()
	_check(instance.screen == "home", "Notebook returns to the screen that opened it")
	instance.screen = "game"
	instance._open_notebook()
	instance._back_from_notebook()
	_check(instance.screen == "game", "Notebook returns to gameplay when opened during a puzzle")

	instance.puzzle_index = 0
	instance.engine.begin_puzzle(0)
	instance.selected_symbol = "sun"
	instance.status_kind = ""
	instance.completed = false
	instance.screen = "home"
	instance._start_game()
	var status_control_id: int = instance.game_status_label.get_instance_id()
	instance._select_symbol("sun")
	_check(instance.game_status_label.get_instance_id() == status_control_id, "Routine gameplay updates reuse the existing HUD controls")
	instance._observe()
	_check(instance.engine.state == "sprout" and instance.status_kind == "solved", "Controller applies rule-engine result to the world state")
	_check(instance.garden.current_state == "sprout", "3D object state follows the puzzle engine")
	instance.queue_free()
	await process_frame

func _finish() -> void:
	if failures.is_empty():
		print("SMOKE_TEST_OK: all %d checks passed" % checks)
		quit(0)
	else:
		push_error("SMOKE_TEST_FAILED: %d failure(s): %s" % [failures.size(), "; ".join(failures)])
		quit(1)
