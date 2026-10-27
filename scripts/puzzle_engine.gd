extends RefCounted

const Catalog = preload("res://scripts/puzzle_catalog.gd")

var state: String = "seed"
var discovered: Array[String] = []

func begin_puzzle(puzzle_index: int) -> void:
	if puzzle_index >= 0 and puzzle_index < Catalog.PUZZLES.size():
		state = str(Catalog.PUZZLES[puzzle_index]["start"])

func restore(saved_state: String, saved_laws: Array[String]) -> void:
	state = saved_state if Catalog.VALID_STATES.has(saved_state) else "seed"
	discovered.clear()
	for law_id in saved_laws:
		if Catalog.KNOWN_LAWS.has(law_id) and not discovered.has(law_id):
			discovered.append(law_id)

## Applies one experiment and returns an explicit result; it does not depend on rendering or UI.
func observe(symbol: String, puzzle_index: int) -> Dictionary:
	if not Catalog.SYMBOLS.has(symbol) or puzzle_index < 0 or puzzle_index >= Catalog.PUZZLES.size():
		return {"changed": false, "state": state, "law_id": "", "new_law": false, "solved": false}
	var key := "%s|%s" % [state, symbol]
	if not Catalog.TRANSITIONS.has(key):
		return {"changed": false, "state": state, "law_id": "", "new_law": false, "solved": false}
	state = str(Catalog.TRANSITIONS[key])
	var law_id := str(Catalog.FEEDBACK.get(key, ""))
	var new_law := false
	if not law_id.is_empty() and not discovered.has(law_id):
		discovered.append(law_id)
		new_law = true
	var goal := str(Catalog.PUZZLES[puzzle_index]["goal"])
	return {"changed": true, "state": state, "law_id": law_id, "new_law": new_law, "solved": state == goal}
