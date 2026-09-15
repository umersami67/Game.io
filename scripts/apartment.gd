extends Node3D

var _materials: Dictionary = {}
var _loop_number := 1

func _ready() -> void:
	_build_apartment()
	apply_loop(1)

func _mat(key: String, color: Color) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	_materials[key] = material
	return material

func _box(name_text: String, position_value: Vector3, size: Vector3, material: Material, collision := true) -> Node3D:
	var holder := Node3D.new()
	holder.name = name_text
	holder.position = position_value
	add_child(holder)

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = material
	holder.add_child(mesh)

	if collision:
		var body := StaticBody3D.new()
		body.name = name_text + "Body"
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
		holder.add_child(body)
	return holder

func _interactive_box(name_text: String, position_value: Vector3, size: Vector3, material: Material, kind: String, prompt: String) -> StaticBody3D:
	var holder := Node3D.new()
	holder.name = name_text
	holder.position = position_value
	add_child(holder)

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = material
	holder.add_child(mesh)

	var body := StaticBody3D.new()
	body.name = name_text + "Body"
	body.set_meta("interactable", true)
	body.set_meta("kind", kind)
	body.set_meta("prompt", prompt)
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	holder.add_child(body)
	return body

func _build_apartment() -> void:
	var wall := _mat("wall", Color("c8c3b8"))
	var floor_mat := _mat("floor", Color("63574a"))
	var trim := _mat("trim", Color("3e3935"))
	var wood := _mat("wood", Color("5d4637"))
	var cloth := _mat("cloth", Color("54565c"))
	var appliance := _mat("appliance", Color("aeb1b3"))
	var dark := _mat("dark", Color("17191b"))
	var mirror_mat := _mat("mirror", Color("819099"))

	# Apartment shell: about 11m x 8m.
	_box("Floor", Vector3(0, -0.10, 0), Vector3(11.0, 0.20, 8.0), floor_mat)
	_box("Ceiling", Vector3(0, 2.90, 0), Vector3(11.0, 0.18, 8.0), wall)
	_box("WestWall", Vector3(-5.45, 1.40, 0), Vector3(0.20, 2.80, 8.0), wall)
	_box("EastWall", Vector3(5.45, 1.40, 0), Vector3(0.20, 2.80, 8.0), wall)
	_box("NorthWall", Vector3(0, 1.40, -3.95), Vector3(11.0, 2.80, 0.20), wall)

	# South wall is split to leave space for the front door.
	_box("SouthWallLeft", Vector3(-1.20, 1.40, 3.95), Vector3(8.40, 2.80, 0.20), wall)
	_box("SouthWallRight", Vector3(5.05, 1.40, 3.95), Vector3(0.80, 2.80, 0.20), wall)
	_interactive_box("FrontDoor", Vector3(3.55, 1.15, 3.91), Vector3(1.20, 2.30, 0.12), wood, "front_door", "Try the front door")
	_box("DoorFrameTop", Vector3(3.55, 2.53, 3.86), Vector3(1.45, 0.16, 0.28), trim)
	_box("DoorFrameLeft", Vector3(2.85, 1.25, 3.86), Vector3(0.14, 2.55, 0.28), trim)
	_box("DoorFrameRight", Vector3(4.25, 1.25, 3.86), Vector3(0.14, 2.55, 0.28), trim)

	# Bedroom wall and doorway.
	_box("BedroomWallLeft", Vector3(-3.85, 1.40, -1.45), Vector3(3.20, 2.80, 0.16), wall)
	_box("BedroomWallRight", Vector3(2.00, 1.40, -1.45), Vector3(4.80, 2.80, 0.16), wall)
	_box("BedroomDoorHeader", Vector3(-1.25, 2.52, -1.45), Vector3(2.00, 0.56, 0.16), wall)

	# Kitchen divider, leaving an open entry.
	_box("KitchenDivider", Vector3(-2.25, 1.40, 1.55), Vector3(0.16, 2.80, 3.00), wall)

	# Small closet in the bedroom.
	_box("ClosetSide", Vector3(3.65, 1.40, -2.75), Vector3(0.16, 2.80, 2.20), wall)
	_box("ClosetFrontA", Vector3(4.45, 1.40, -1.70), Vector3(1.45, 2.80, 0.16), wall)

	# Living room baseline furniture.
	_box("SofaBase", Vector3(0.45, 0.33, 1.25), Vector3(2.60, 0.55, 0.85), cloth)
	_box("SofaBack", Vector3(0.45, 0.92, 1.60), Vector3(2.60, 0.85, 0.18), cloth)
	_box("CoffeeTable", Vector3(0.40, 0.30, 0.00), Vector3(1.45, 0.12, 0.80), wood)
	_box("TVStand", Vector3(3.55, 0.42, 0.70), Vector3(1.60, 0.60, 0.45), wood)
	_box("TV", Vector3(3.55, 1.28, 0.77), Vector3(1.45, 0.82, 0.10), dark)

	# Kitchen furniture/appliances.
	_box("KitchenCounter", Vector3(-4.35, 0.48, 2.35), Vector3(1.75, 0.90, 0.62), appliance)
	_box("KitchenCounterBack", Vector3(-4.95, 0.48, 0.40), Vector3(0.75, 0.90, 2.45), appliance)
	_box("Fridge", Vector3(-3.15, 1.05, 2.85), Vector3(0.82, 2.10, 0.82), appliance)

	# Bedroom furniture.
	_box("BedBase", Vector3(-3.40, 0.35, -2.78), Vector3(2.45, 0.58, 1.65), wood)
	_box("Mattress", Vector3(-3.40, 0.69, -2.78), Vector3(2.30, 0.25, 1.55), _mat("mattress", Color("b7b4aa")))
	_box("Nightstand", Vector3(-1.75, 0.42, -3.15), Vector3(0.62, 0.84, 0.62), wood)

	# Hallway mirror: deliberately unavoidable on the route between rooms.
	var mirror_holder := Node3D.new()
	mirror_holder.name = "HallwayMirror"
	mirror_holder.position = Vector3(2.55, 1.48, -1.33)
	add_child(mirror_holder)
	var mirror_mesh := MeshInstance3D.new()
	var mirror_box := BoxMesh.new()
	mirror_box.size = Vector3(1.10, 1.65, 0.05)
	mirror_mesh.mesh = mirror_box
	mirror_mesh.material_override = mirror_mat
	mirror_holder.add_child(mirror_mesh)
	var mirror_body := StaticBody3D.new()
	mirror_body.set_meta("interactable", true)
	mirror_body.set_meta("kind", "mirror")
	mirror_body.set_meta("prompt", "Look at the mirror")
	var mirror_shape := CollisionShape3D.new()
	var mirror_collision := BoxShape3D.new()
	mirror_collision.size = Vector3(1.10, 1.65, 0.08)
	mirror_shape.shape = mirror_collision
	mirror_body.add_child(mirror_shape)
	mirror_holder.add_child(mirror_body)

	# Warm apartment lights. Later loops will alter these.
	_add_light("LivingLight", Vector3(0.2, 2.55, 0.8), Color("ffd8a8"), 1.9, 7.0)
	_add_light("BedroomLight", Vector3(-2.6, 2.55, -2.7), Color("ffe0b5"), 1.5, 5.0)
	_add_light("KitchenLight", Vector3(-4.0, 2.55, 1.7), Color("f1e6cf"), 1.25, 4.5)

func _add_light(name_text: String, pos: Vector3, color: Color, energy: float, range_value: float) -> void:
	var light := OmniLight3D.new()
	light.name = name_text
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	light.shadow_enabled = true
	add_child(light)

func apply_loop(loop_number: int) -> void:
	_loop_number = clamp(loop_number, 1, 5)
	var living_light := get_node_or_null("LivingLight") as OmniLight3D
	var bedroom_light := get_node_or_null("BedroomLight") as OmniLight3D
	var kitchen_light := get_node_or_null("KitchenLight") as OmniLight3D

	if living_light:
		living_light.light_energy = max(0.55, 1.9 - float(_loop_number - 1) * 0.28)
	if bedroom_light:
		bedroom_light.light_energy = max(0.45, 1.5 - float(_loop_number - 1) * 0.20)
	if kitchen_light:
		kitchen_light.light_energy = max(0.35, 1.25 - float(_loop_number - 1) * 0.18)

	# Tiny baseline environmental changes. These will become bespoke per-loop events later.
	var table := get_node_or_null("CoffeeTable")
	if table:
		table.rotation.y = deg_to_rad(float(_loop_number - 1) * 1.8)

	var tv := get_node_or_null("TV")
	if tv:
		tv.position.x = 3.55 + float(_loop_number - 1) * 0.025
