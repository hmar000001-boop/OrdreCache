extends Node3D

signal target_selected
signal symbol_selected(symbol: String)

const AMBIENT_STREAM = preload("res://assets/audio/garden_ambience.wav")

var camera: Camera3D
var target_area: Area3D
var visual_root: Node3D
var current_state := "seed"
var selected_symbol := "sun"
var symbol_areas: Dictionary = {}
var fireflies: Array[MeshInstance3D] = []
var firefly_origins: Array[Vector3] = []
var elapsed := 0.0
var ambient_player: AudioStreamPlayer
var object_state_tween: Tween

const SYMBOL_COLORS: Dictionary = {
	"sun": Color("f4c56a"),
	"rain": Color("7dc7e8"),
	"moon": Color("c3b7ef"),
	"wind": Color("9be1c5")
}

func _ready() -> void:
	_build_environment()
	_build_ground_and_path()
	_build_garden_plants()
	_build_fireflies()
	_build_altar()
	_build_symbol_stones()
	_build_target()
	set_object_state(current_state)
	_start_ambience()

func activate_interaction(interaction_id: String) -> void:
	if interaction_id == "target":
		target_selected.emit()
	elif interaction_id.begins_with("symbol:"):
		var symbol_id := interaction_id.trim_prefix("symbol:")
		if SYMBOL_COLORS.has(symbol_id):
			symbol_selected.emit(symbol_id)

func _process(delta: float) -> void:
	elapsed += delta
	if is_instance_valid(camera):
		camera.position.x = sin(elapsed * 0.17) * 0.08
		camera.position.y = 6.4 + sin(elapsed * 0.11) * 0.025
		camera.look_at(Vector3(0.0, 0.35, -0.1), Vector3.UP)
	for index in range(fireflies.size()):
		var fly := fireflies[index]
		if is_instance_valid(fly):
			var origin: Vector3 = firefly_origins[index]
			fly.position = origin + Vector3(sin(elapsed * 0.65 + float(index)) * 0.16, sin(elapsed * 0.9 + float(index) * 1.4) * 0.12, cos(elapsed * 0.57 + float(index)) * 0.12)

func _start_ambience() -> void:
	ambient_player = AudioStreamPlayer.new()
	ambient_player.name = "GardenAmbience"
	ambient_player.stream = AMBIENT_STREAM
	ambient_player.volume_db = -12.0
	var ambience_wav := ambient_player.stream as AudioStreamWAV
	if ambience_wav != null:
		# AudioStreamWAV loop points are measured in sample frames, not seconds.
		ambience_wav.loop_begin = 0
		ambience_wav.loop_end = int(ambience_wav.mix_rate * ambience_wav.get_length())
		ambience_wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	add_child(ambient_player)
	ambient_player.play()

func _build_environment() -> void:
	var environment_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("111e2b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("abc7c2")
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("263c3b")
	env.fog_density = 0.012
	environment_node.environment = env
	add_child(environment_node)

	var key_light := DirectionalLight3D.new()
	key_light.name = "MoonlitCanopy"
	key_light.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	key_light.light_color = Color("d9e7dc")
	key_light.light_energy = 1.25
	key_light.shadow_enabled = true
	add_child(key_light)

	var fill := OmniLight3D.new()
	fill.name = "AltarGlow"
	fill.position = Vector3(0.0, 3.2, -0.4)
	fill.light_color = Color("7bd8b5")
	fill.light_energy = 0.65
	fill.omni_range = 6.0
	add_child(fill)

	camera = Camera3D.new()
	camera.name = "GardenCamera"
	camera.position = Vector3(0.0, 6.4, 10.4)
	camera.fov = 42.0
	camera.near = 0.1
	camera.far = 70.0
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.35, -0.1), Vector3.UP)
	camera.current = true

func _build_ground_and_path() -> void:
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(42.0, 42.0)
	_add_mesh(self, ground_mesh, _mat(Color("203b35"), 0.96), Vector3(0.0, -0.14, -3.0))

	# A readable stone path leads from the foreground to the central altar.
	for index in range(9):
		var slab := BoxMesh.new()
		slab.size = Vector3(1.18, 0.10, 0.74)
		var shade := Color("53675d") if index % 2 == 0 else Color("435b54")
		_add_mesh(self, slab, _mat(shade, 0.9), Vector3(0.0, -0.015, 4.6 - float(index) * 0.9))
		# Small side stones make the path feel placed rather than tiled.
		if index % 2 == 0:
			_add_mesh(self, _box(Vector3(0.28, 0.08, 0.34)), _mat(Color("344e46")), Vector3(-0.82, 0.0, 4.45 - float(index) * 0.9))
			_add_mesh(self, _box(Vector3(0.28, 0.08, 0.34)), _mat(Color("344e46")), Vector3(0.82, 0.0, 4.75 - float(index) * 0.9))

func _build_garden_plants() -> void:
	var tree_positions: Array[Vector3] = [
		Vector3(-6.0, 0.0, -5.0), Vector3(-4.4, 0.0, -7.0), Vector3(-7.6, 0.0, -1.0),
		Vector3(6.0, 0.0, -4.8), Vector3(4.6, 0.0, -7.2), Vector3(7.4, 0.0, -0.8),
		Vector3(-5.7, 0.0, 2.8), Vector3(5.8, 0.0, 2.6)
	]
	for index in range(tree_positions.size()):
		var p: Vector3 = tree_positions[index]
		var trunk_height := 2.1 + float(index % 3) * 0.35
		_add_mesh(self, _cylinder(0.22, trunk_height), _mat(Color("4a5140")), p + Vector3(0.0, trunk_height * 0.5, 0.0))
		var crown_color := Color("234a3e") if index % 2 == 0 else Color("2e5946")
		_add_mesh(self, _sphere(1.0), _mat(crown_color, 0.98), p + Vector3(0.0, trunk_height + 0.55, 0.0), Vector3(1.2, 1.25, 1.1))
		_add_mesh(self, _sphere(0.72), _mat(Color("315f4a")), p + Vector3(0.48, trunk_height + 0.25, 0.15), Vector3(1.15, 1.0, 1.0))

	# Fern-like silhouettes and low plants along the edges.
	for index in range(12):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -5.3 + float(index) * 0.82
		var x := side * (3.0 + float(index % 3) * 0.55)
		var plant := Node3D.new()
		plant.position = Vector3(x, 0.0, z)
		add_child(plant)
		_add_mesh(plant, _cylinder(0.045, 0.48), _mat(Color("3e7a58")), Vector3(0.0, 0.23, 0.0))
		for leaf_index in range(3):
			var leaf := _sphere(0.16)
			_add_mesh(plant, leaf, _mat(Color("4f9668")), Vector3((float(leaf_index) - 1.0) * 0.16, 0.30 + float(leaf_index % 2) * 0.10, 0.0), Vector3(1.45, 0.38, 0.75))

func _build_fireflies() -> void:
	for index in range(14):
		var angle := TAU * float(index) / 14.0
		var radius := 2.8 + float(index % 4) * 0.78
		var origin := Vector3(cos(angle) * radius, 0.45 + float(index % 5) * 0.34, -1.2 + sin(angle) * 3.8)
		var mote := _add_mesh(self, _sphere(0.035 + float(index % 2) * 0.012), _mat(Color("a8f0d1"), 0.2, 0.0, true), origin)
		mote.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		fireflies.append(mote)
		firefly_origins.append(origin)

func _build_altar() -> void:
	_add_mesh(self, _cylinder(1.45, 0.28, 48), _mat(Color("354d4e"), 0.64, 0.18), Vector3(0.0, 0.16, -0.25))
	_add_mesh(self, _cylinder(1.20, 0.13, 48), _mat(Color("667a70"), 0.7, 0.12), Vector3(0.0, 0.34, -0.25))
	_add_mesh(self, _cylinder(0.95, 0.045, 48), _mat(Color("9bb9a8"), 0.55, 0.15), Vector3(0.0, 0.43, -0.25))
	# Broken fragments around the altar add scale and help frame the central object.
	for piece in range(7):
		var angle := TAU * float(piece) / 7.0
		var rock := _sphere(0.24 + float(piece % 2) * 0.05)
		var pos := Vector3(cos(angle) * 1.75, 0.22, -0.25 + sin(angle) * 1.2)
		_add_mesh(self, rock, _mat(Color("52665a")), pos, Vector3(1.45, 0.70, 1.15))

func _build_symbol_stones() -> void:
	var definitions: Array[Dictionary] = [
		{"id": "sun", "pos": Vector3(-1.58, 0.06, -0.5)},
		{"id": "rain", "pos": Vector3(1.58, 0.06, -0.5)},
		{"id": "moon", "pos": Vector3(-1.48, 0.06, -2.45)},
		{"id": "wind", "pos": Vector3(1.48, 0.06, -2.45)}
	]
	for definition in definitions:
		var symbol_id := str(definition["id"])
		var area := Area3D.new()
		area.name = "Symbol_%s" % symbol_id.capitalize()
		area.position = definition["pos"]
		area.collision_layer = 1
		area.collision_mask = 0
		area.input_ray_pickable = true
		area.set_meta("interaction_id", "symbol:%s" % symbol_id)
		add_child(area)
		var collision := CollisionShape3D.new()
		var sphere_shape := SphereShape3D.new()
		sphere_shape.radius = 0.72
		collision.shape = sphere_shape
		collision.position.y = 0.5
		area.add_child(collision)

		_add_mesh(area, _cylinder(0.46, 0.72, 24), _mat(Color("3b504d"), 0.76, 0.18), Vector3(0.0, 0.36, 0.0))
		var symbol_cap := _add_mesh(area, _cylinder(0.38, 0.08, 24), _mat(Color("687b6e")), Vector3(0.0, 0.76, 0.0))
		symbol_cap.name = "SymbolCap"
		_add_symbol_shape(area, symbol_id)
		var label := Label3D.new()
		label.name = "SymbolLabel"
		label.text = _symbol_glyph(symbol_id)
		label.font_size = 48
		label.pixel_size = 0.006
		label.position = Vector3(0.0, 1.0, 0.0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = SYMBOL_COLORS[symbol_id]
		label.outline_size = 6
		label.outline_modulate = Color("162923")
		area.add_child(label)
		symbol_areas[symbol_id] = area

func _add_symbol_shape(parent: Node3D, symbol_id: String) -> void:
	var glow_mat := _mat(SYMBOL_COLORS[symbol_id], 0.42, 0.1, true)
	if symbol_id == "sun":
		_add_mesh(parent, _sphere(0.16), glow_mat, Vector3(0.0, 0.89, 0.0))
		for index in range(8):
			var angle := TAU * float(index) / 8.0
			_add_mesh(parent, _cylinder(0.025, 0.23, 8), glow_mat, Vector3(cos(angle) * 0.27, 0.89, sin(angle) * 0.27))
	elif symbol_id == "rain":
		for index in range(3):
			_add_mesh(parent, _cylinder(0.035, 0.25, 8), glow_mat, Vector3((float(index) - 1.0) * 0.18, 0.9, 0.0), Vector3(0.0, 0.0, -18.0))
	elif symbol_id == "moon":
		_add_mesh(parent, _sphere(0.23), glow_mat, Vector3(0.0, 0.9, 0.0), Vector3(0.0, 0.0, 0.0))
		_add_mesh(parent, _sphere(0.20), _mat(Color("687b6e")), Vector3(0.12, 0.96, 0.06))
	else:
		for index in range(3):
			_add_mesh(parent, _sphere(0.07), glow_mat, Vector3((float(index) - 1.0) * 0.2, 0.9, 0.0), Vector3(1.4, 0.55, 0.7))

func _build_target() -> void:
	target_area = Area3D.new()
	target_area.name = "InteractiveMysteryObject"
	target_area.position = Vector3(0.0, 0.80, -0.25)
	target_area.collision_layer = 1
	target_area.collision_mask = 0
	target_area.input_ray_pickable = true
	target_area.set_meta("interaction_id", "target")
	add_child(target_area)
	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.78
	shape_node.shape = shape
	target_area.add_child(shape_node)
	visual_root = Node3D.new()
	visual_root.name = "ObjectVisual"
	target_area.add_child(visual_root)

func rotate_target_object(delta: Vector2) -> void:
	if not is_instance_valid(visual_root):
		return
	visual_root.rotation.y -= delta.x * 0.012
	visual_root.rotation.x = clampf(visual_root.rotation.x + delta.y * 0.006, deg_to_rad(-18.0), deg_to_rad(18.0))

func set_selected_symbol(symbol_id: String) -> void:
	selected_symbol = symbol_id
	for key in symbol_areas:
		var area: Area3D = symbol_areas[key]
		var base_color: Color = SYMBOL_COLORS[key]
		var disc := area.get_node_or_null("SymbolCap") as MeshInstance3D
		if is_instance_valid(disc):
			disc.material_override = _mat(base_color.lightened(0.24) if key == selected_symbol else Color("687b6e"), 0.72, 0.2)

func set_object_state(new_state: String) -> void:
	current_state = new_state
	var altar_light := get_node_or_null("AltarGlow") as OmniLight3D
	if is_instance_valid(altar_light):
		altar_light.light_color = Color("a6f3d0") if current_state in ["stone_marked", "stone_open", "bloom"] else Color("7bd8b5")
		altar_light.light_energy = 0.95 if current_state in ["stone_open", "bloom"] else 0.65
	if not is_instance_valid(visual_root):
		return
	for child in visual_root.get_children():
		visual_root.remove_child(child)
		child.queue_free()
	visual_root.rotation = Vector3.ZERO
	if is_instance_valid(object_state_tween) and object_state_tween.is_running():
		object_state_tween.kill()
	var scale_factor := 0.94
	visual_root.scale = Vector3.ONE * scale_factor
	match current_state:
		"seed": _draw_seed()
		"sprout": _draw_sprout()
		"sapling": _draw_sapling()
		"bloom": _draw_bloom()
		"carried": _draw_carried_seed()
		"stone_cold": _draw_stone(Color("71838b"), false, false)
		"stone_warm": _draw_stone(Color("bd8760"), true, false)
		"stone_marked": _draw_stone(Color("718d87"), false, true)
		"stone_open": _draw_open_stone()
		_: _draw_seed()
	object_state_tween = create_tween()
	object_state_tween.tween_property(visual_root, "scale", Vector3.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw_seed() -> void:
	_add_mesh(visual_root, _sphere(0.31), _mat(Color("9e794e"), 0.48, 0.16), Vector3(0.0, 0.0, 0.0), Vector3(1.0, 1.25, 0.8))
	_add_mesh(visual_root, _sphere(0.14), _mat(Color("d9b56a"), 0.32, 0.1), Vector3(0.08, 0.14, 0.05), Vector3(0.6, 1.0, 0.6))

func _draw_sprout() -> void:
	_add_mesh(visual_root, _cylinder(0.055, 0.54, 12), _mat(Color("71b77c")), Vector3(0.0, 0.02, 0.0), Vector3(1.0, 1.0, 1.0))
	_add_mesh(visual_root, _sphere(0.20), _mat(Color("71c98a")), Vector3(-0.17, 0.12, 0.0), Vector3(1.3, 0.5, 0.7), Vector3(0.0, 0.0, -28.0))
	_add_mesh(visual_root, _sphere(0.19), _mat(Color("9de19a")), Vector3(0.17, 0.22, 0.0), Vector3(1.2, 0.48, 0.7), Vector3(0.0, 0.0, 25.0))

func _draw_sapling() -> void:
	_add_mesh(visual_root, _cylinder(0.085, 0.88, 12), _mat(Color("725c40")), Vector3(0.0, 0.04, 0.0))
	_add_mesh(visual_root, _sphere(0.38), _mat(Color("3b8257")), Vector3(0.0, 0.49, 0.0), Vector3(1.0, 1.2, 0.9))
	_add_mesh(visual_root, _sphere(0.28), _mat(Color("60a66a")), Vector3(-0.26, 0.25, 0.08))
	_add_mesh(visual_root, _sphere(0.28), _mat(Color("4b9661")), Vector3(0.27, 0.30, -0.06))

func _draw_bloom() -> void:
	_add_mesh(visual_root, _cylinder(0.06, 0.85, 12), _mat(Color("64aa70")), Vector3(0.0, -0.02, 0.0))
	_add_mesh(visual_root, _sphere(0.23), _mat(Color("5caa6f")), Vector3(-0.17, 0.10, 0.0), Vector3(1.3, 0.46, 0.75))
	for index in range(7):
		var angle := TAU * float(index) / 7.0
		_add_mesh(visual_root, _sphere(0.19), _mat(Color("dfb6d7")), Vector3(cos(angle) * 0.24, 0.49 + sin(angle) * 0.18, 0.0), Vector3(0.90, 0.68, 0.70))
	_add_mesh(visual_root, _sphere(0.15), _mat(Color("f4d88e"), 0.3), Vector3(0.0, 0.48, -0.02))

func _draw_carried_seed() -> void:
	_draw_seed()
	_add_mesh(visual_root, _sphere(0.035), _mat(Color("a7efd5"), 0.24, 0.0, true), Vector3(-0.42, 0.36, 0.0))
	_add_mesh(visual_root, _sphere(0.025), _mat(Color("a7efd5"), 0.24, 0.0, true), Vector3(0.40, 0.18, 0.0))
	_add_mesh(visual_root, _sphere(0.03), _mat(Color("a7efd5"), 0.24, 0.0, true), Vector3(0.05, -0.28, 0.0))

func _draw_stone(color: Color, warm: bool, marked: bool) -> void:
	_add_mesh(visual_root, _box(Vector3(0.92, 0.64, 0.74)), _mat(color, 0.68, 0.12), Vector3(0.0, 0.0, 0.0), Vector3(0.0, 0.0, -5.0))
	_add_mesh(visual_root, _box(Vector3(0.72, 0.10, 0.68)), _mat(color.darkened(0.24)), Vector3(0.0, -0.32, 0.0))
	if warm:
		_add_mesh(visual_root, _sphere(0.12), _mat(Color("ffc77d"), 0.25, 0.0, true), Vector3(0.0, 0.12, 0.39))
	if marked:
		_add_mesh(visual_root, _box(Vector3(0.10, 0.34, 0.035)), _mat(Color("a8e6d0"), 0.24, 0.0, true), Vector3(0.0, 0.02, 0.39))
		_add_mesh(visual_root, _box(Vector3(0.30, 0.08, 0.035)), _mat(Color("a8e6d0"), 0.24, 0.0, true), Vector3(0.0, 0.04, 0.39))

func _draw_open_stone() -> void:
	_add_mesh(visual_root, _box(Vector3(0.42, 0.65, 0.70)), _mat(Color("718d87"), 0.58, 0.12), Vector3(-0.29, 0.0, 0.0), Vector3(0.0, 0.0, -7.0))
	_add_mesh(visual_root, _box(Vector3(0.42, 0.65, 0.70)), _mat(Color("809991"), 0.58, 0.12), Vector3(0.29, 0.02, 0.0), Vector3(0.0, 0.0, 7.0))
	_add_mesh(visual_root, _sphere(0.19), _mat(Color("a4f1ce"), 0.24, 0.0, true), Vector3(0.0, 0.0, 0.30))

func _add_mesh(parent: Node3D, mesh: Mesh, material: Material, pos: Vector3, scale_value: Vector3 = Vector3.ONE, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.rotation_degrees = rotation_value
	parent.add_child(instance)
	return instance

func _mat(color: Color, roughness: float = 0.82, metallic: float = 0.0, emissive: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.2
	return material

func _sphere(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	return mesh

func _cylinder(radius: float, height: float, segments: int = 20) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	return mesh

func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _symbol_glyph(symbol_id: String) -> String:
	return str({"sun": "☼", "rain": "≋", "moon": "☾", "wind": "≈"}.get(symbol_id, "✦"))
