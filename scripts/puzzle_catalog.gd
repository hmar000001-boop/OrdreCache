extends RefCounted

## Puzzle data is kept independent of the renderer and UI so it can be tested without a scene.
const SYMBOLS: Array[String] = ["sun", "rain", "moon", "wind"]
const KNOWN_LAWS: Array[String] = [
	"rule_sun", "rule_rain", "rule_moon", "rule_wind",
	"rule_stone_sun", "rule_stone_moon", "rule_stone_wind"
]

const PUZZLES: Array[Dictionary] = [
	{"title": "p1_title", "desc": "p1_desc", "start": "seed", "goal": "sprout", "first": "sun", "hint": "hint1"},
	{"title": "p2_title", "desc": "p2_desc", "start": "sprout", "goal": "sapling", "first": "rain", "hint": "hint2"},
	{"title": "p3_title", "desc": "p3_desc", "start": "sapling", "goal": "bloom", "first": "moon", "hint": "hint2"},
	{"title": "p4_title", "desc": "p4_desc", "start": "seed", "goal": "carried", "first": "wind", "hint": "hint1"},
	{"title": "p5_title", "desc": "p5_desc", "start": "stone_cold", "goal": "stone_open", "first": "sun", "hint": "hint3"},
	{"title": "p6_title", "desc": "p6_desc", "start": "seed", "goal": "bloom", "first": "sun", "hint": "hint3"}
]

const TRANSITIONS: Dictionary = {
	"seed|sun": "sprout",
	"seed|wind": "carried",
	"sprout|rain": "sapling",
	"sapling|moon": "bloom",
	"stone_cold|sun": "stone_warm",
	"stone_warm|moon": "stone_marked",
	"stone_marked|wind": "stone_open"
}

const FEEDBACK: Dictionary = {
	"seed|sun": "rule_sun",
	"sprout|rain": "rule_rain",
	"sapling|moon": "rule_moon",
	"seed|wind": "rule_wind",
	"stone_cold|sun": "rule_stone_sun",
	"stone_warm|moon": "rule_stone_moon",
	"stone_marked|wind": "rule_stone_wind"
}

const VALID_STATES: Array[String] = [
	"seed", "sprout", "sapling", "bloom", "carried",
	"stone_cold", "stone_warm", "stone_marked", "stone_open"
]

static func valid_state_for_puzzle(state: String, puzzle_index: int) -> bool:
	if not VALID_STATES.has(state) or puzzle_index < 0 or puzzle_index >= PUZZLES.size():
		return false
	# Keep legitimate dead-end experiments on resume while rejecting states from another puzzle family.
	# Reachability is derived from the transition graph, so content changes do not need a second allow-list.
	var reachable: Array[String] = [str(PUZZLES[puzzle_index]["start"])]
	var scan_index := 0
	while scan_index < reachable.size():
		var current_state := reachable[scan_index]
		scan_index += 1
		for transition_key in TRANSITIONS:
			var parts: PackedStringArray = str(transition_key).split("|")
			if parts.size() == 2 and parts[0] == current_state:
				var next_state := str(TRANSITIONS[transition_key])
				if not reachable.has(next_state):
					reachable.append(next_state)
	return reachable.has(state)
