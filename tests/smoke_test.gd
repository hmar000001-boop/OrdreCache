extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> void:
    if condition:
        print("PASS: ", message)
    else:
        failures.append(message)
        push_error("FAIL: " + message)

func _run() -> void:
    print("SMOKE_TEST_START: loading main scene")
    var packed: PackedScene = load("res://scenes/main.tscn")
    _check(packed != null, "Main scene resource loads")
    if packed == null:
        _finish()
        return

    var instance := packed.instantiate()
    _check(instance != null, "Main scene instantiates")
    if instance == null:
        _finish()
        return
    root.add_child(instance)
    await process_frame
    var game: Variant = instance

    game.puzzle_index = 0
    game.object_state = "seed"
    game.selected_symbol = "sun"
    game.screen = "game"
    game.status_text = ""
    game.status_success = false
    game._observe()
    _check(game.object_state == "sprout", "Sun wakes the seed")
    _check(game.status_success, "Puzzle 1 solved after applying sun")
    _check(game.discovered.has("rule_sun"), "Observed law is written to notebook")

    game.puzzle_index = 4
    game.object_state = "stone_cold"
    game.selected_symbol = "sun"
    game.status_text = ""
    game.status_success = false
    game._observe()
    _check(game.object_state == "stone_warm", "Sun warms the stone")
    game.selected_symbol = "moon"
    game._observe()
    _check(game.object_state == "stone_marked", "Moon reveals the hidden mark")
    game.selected_symbol = "wind"
    game._observe()
    _check(game.object_state == "stone_open", "Wind opens the marked stone")
    _check(game.status_success, "Stone puzzle solved after the sequence")

    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("SMOKE_TEST_OK: all gameplay checks passed")
        quit(0)
    else:
        push_error("SMOKE_TEST_FAILED: %d check(s) failed: %s" % [failures.size(), "; ".join(failures)])
        quit(1)
