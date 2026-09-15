extends Node3D

const APARTMENT_SCRIPT := preload("res://scripts/apartment.gd")
const PLAYER_START := Vector3(0.0, 1.0, 2.2)
const JUNGLE_START := Vector3(0.0, 1.0, 7.0)

@onready var player: CharacterBody3D = $Player
@onready var prompt_label: Label = $HUD/Prompt

var apartment: Node3D
var jungle: Node3D
var current_loop := 1
var door_attempts := 0
var mirror_engaged := false
var transitioning := false
var escaped := false

func _ready() -> void:
	_build_environment()
	apartment = Node3D.new()
	apartment.name = "Apartment"
	apartment.set_script(APARTMENT_SCRIPT)
	add_child(apartment)

	player.prompt_changed.connect(_on_prompt_changed)
	player.interacted.connect(_on_player_interacted)
	player.reset_to(PLAYER_START, 0.0)

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("17191d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("9ba0a8")
	env.ambient_light_energy = 0.32
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = env
	add_child(world_environment)

func _on_prompt_changed(text: String) -> void:
	if not transitioning:
		prompt_label.text = text

func _on_player_interacted(target: Object) -> void:
	if transitioning or escaped or not target.has_meta("kind"):
		return

	match str(target.get_meta("kind")):
		"front_door":
			_try_front_door()
		"mirror":
			_interact_with_mirror()

func _try_front_door() -> void:
	door_attempts += 1
	transitioning = true

	if current_loop == 1:
		prompt_label.text = "The handle turns. A voice behind you whispers: Don't."
	elif current_loop == 2:
		prompt_label.text = "Locked. You don't remember locking it."
	elif current_loop == 3:
		prompt_label.text = "The hallway behind you creaks once."
	elif current_loop == 4:
		prompt_label.text = "A tired voice says: You keep trying that door."
	else:
		prompt_label.text = "The lock turns. This time, the door opens."

	await get_tree().create_timer(1.45).timeout
	if current_loop < 5:
		_advance_loop()
	else:
		await _escape_to_jungle()

func _advance_loop() -> void:
	current_loop += 1
	player.reset_to(PLAYER_START, 0.0)
	if apartment and apartment.has_method("apply_loop"):
		apartment.call("apply_loop", current_loop)

	prompt_label.text = ""
	transitioning = false

func _interact_with_mirror() -> void:
	if current_loop < 3:
		prompt_label.text = "Just your reflection."
		return

	mirror_engaged = true
	if current_loop == 3:
		prompt_label.text = "Your reflection stops a fraction too late."
	elif current_loop == 4:
		prompt_label.text = "It looks more certain than you do."
	else:
		prompt_label.text = "It is already looking at you."

func _escape_to_jungle() -> void:
	escaped = true
	prompt_label.text = "Cold rain hits your face. There should not be a forest here."

	if apartment and is_instance_valid(apartment):
		apartment.queue_free()
		apartment = null

	_build_jungle_escape()
	_set_jungle_environment()
	player.reset_to(JUNGLE_START, PI)

	await get_tree().create_timer(3.0).timeout
	prompt_label.text = "THE TENANT — END OF CHAPTER ONE"
	await get_tree().create_timer(4.0).timeout
	prompt_label.text = ""
	transitioning = false

func _set_jungle_environment() -> void:
	var world_environment := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		return

	var env := world_environment.environment
	env.background_color = Color("05090a")
	env.ambient_light_color = Color("364445")
	env.ambient_light_energy = 0.18
	env.fog_enabled = true
	env.fog_light_color = Color("536363")
	env.fog_light_energy = 0.35
	env.fog_density = 0.055

func _build_jungle_escape() -> void:
	jungle = Node3D.new()
	jungle.name = "JungleEscape"
	add_child(jungle)

	_create_static_box(jungle, "Ground", Vector3(0.0, -0.25, 0.0), Vector3(30.0, 0.5, 30.0), Color("111b13"))

	var path := _create_visual_box(jungle, "WetPath", Vector3(0.0, 0.015, -2.0), Vector3(2.2, 0.03, 24.0), Color("242a24"))
	path.rotation_degrees.y = -4.0

	var tree_positions := [
		Vector3(-3.8, 0.0, 4.0), Vector3(4.1, 0.0, 3.0), Vector3(-5.0, 0.0, -1.0),
		Vector3(5.4, 0.0, -2.5), Vector3(-3.4, 0.0, -6.0), Vector3(3.5, 0.0, -7.0),
		Vector3(-6.5, 0.0, -9.0), Vector3(6.8, 0.0, -10.0), Vector3(-2.5, 0.0, -12.0),
		Vector3(2.8, 0.0, -14.0), Vector3(-7.0, 0.0, 7.0), Vector3(7.4, 0.0, 6.5)
	]

	for i in range(tree_positions.size()):
		_create_tree(jungle, "Tree_%02d" % i, tree_positions[i], 3.6 + float(i % 4) * 0.55)

	var moon := DirectionalLight3D.new()
	moon.name = "ColdMoonlight"
	moon.light_color = Color("8ca5a8")
	moon.light_energy = 0.42
	moon.shadow_enabled = true
	moon.rotation_degrees = Vector3(-58.0, -22.0, 0.0)
	jungle.add_child(moon)

	var doorway_light := OmniLight3D.new()
	doorway_light.name = "ApartmentAfterglow"
	doorway_light.position = Vector3(0.0, 2.1, 8.8)
	doorway_light.light_color = Color("d7c49c")
	doorway_light.light_energy = 1.25
	doorway_light.omni_range = 8.0
	jungle.add_child(doorway_light)

func _create_tree(parent: Node3D, node_name: String, base_position: Vector3, height: float) -> void:
	var trunk := StaticBody3D.new()
	trunk.name = node_name
	trunk.position = base_position + Vector3(0.0, height * 0.5, 0.0)
	parent.add_child(trunk)

	var mesh_instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.24
	cylinder.bottom_radius = 0.38
	cylinder.height = height
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = _make_material(Color("34271e"), 0.92)
	trunk.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = 0.38
	cylinder_shape.height = height
	collision.shape = cylinder_shape
	trunk.add_child(collision)

	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.7
	sphere.height = 2.7
	crown.mesh = sphere
	crown.position = base_position + Vector3(0.0, height + 0.7, 0.0)
	crown.material_override = _make_material(Color("0d2415"), 1.0)
	parent.add_child(crown)

func _create_static_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	parent.add_child(body)

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_material(color, 0.96)
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body

func _create_visual_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_material(color, 0.82)
	parent.add_child(mesh_instance)
	return mesh_instance

func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
