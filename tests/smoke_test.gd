extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	assert(packed != null, "Main scene must load")
	var game: Variant = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.puzzle_index = 0
	game.object_state = "seed"
	game.selected_symbol = "sun"
	game.screen = "game"
	game.status_text = ""
	game.status_success = false
	game._observe()
	assert(game.object_state == "sprout", "Sun must wake the seed")
	assert(game.status_success, "Puzzle 1 should be solved after applying sun")
	assert(game.discovered.has("rule_sun"), "The observed law must be written to notebook")
	game.puzzle_index = 4
	game.object_state = "stone_cold"
	game.selected_symbol = "sun"
	game.status_text = ""
	game.status_success = false
	game._observe()
	assert(game.object_state == "stone_warm", "Sun should warm the stone")
	game.selected_symbol = "moon"
	game._observe()
	assert(game.object_state == "stone_marked", "Moon should reveal the hidden mark")
	game.selected_symbol = "wind"
	game._observe()
	assert(game.object_state == "stone_open", "Wind should open the marked stone")
	assert(game.status_success, "The stone puzzle should be solved after the sequence")
	print("SMOKE_TEST_OK: scene load, seed law, notebook discovery, and stone sequence")
	quit(0)
