extends Node3D

const APARTMENT_SCRIPT := preload("res://scripts/apartment.gd")
const PLAYER_START := Vector3(0.0, 1.0, 2.2)
const JUNGLE_START := Vector3(0.0, 1.0, 7.0)

@onready var player: CharacterBody3D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var crosshair: Label = $HUD/Crosshair
@onready var prompt_label: Label = $HUD/Prompt
@onready var pause_hint: Label = $HUD/LoopLabel

var apartment: Node3D
var jungle: Node3D
var current_loop := 1
var door_attempts := 0
var mirror_engaged := false
var transitioning := false
var escaped := false

var game_started := false
var is_paused := false
var graphics_preset := 1
var main_menu: ColorRect
var pause_menu: ColorRect
var main_graphics_option: OptionButton
var pause_graphics_option: OptionButton

func _ready() -> void:
	# The controller must keep receiving P while the SceneTree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	_build_environment()
	apartment = Node3D.new()
	apartment.name = "Apartment"
	apartment.set_script(APARTMENT_SCRIPT)
	apartment.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(apartment)

	player.prompt_changed.connect(_on_prompt_changed)
	player.interacted.connect(_on_player_interacted)
	player.reset_to(PLAYER_START, 0.0)

	_build_frontend()
	_apply_graphics_preset(graphics_preset)
	_show_main_menu()

func _input(event: InputEvent) -> void:
	if not game_started:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_P:
		if transitioning:
			return
		get_viewport().set_input_as_handled()
		if is_paused:
			_resume_game()
		else:
			_pause_game()

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

func _build_frontend() -> void:
	pause_hint.text = "P = Pause"
	pause_hint.visible = false

	main_menu = _create_menu_overlay(Color(0.015, 0.017, 0.021, 0.98))
	main_menu.name = "MainMenu"
	hud.add_child(main_menu)
	var main_box := _create_menu_box(main_menu)

	var title := Label.new()
	title.text = "THE TENANT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	main_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "PSYCHOLOGICAL HORROR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.68, 0.69, 0.72, 1.0)
	subtitle.add_theme_font_size_override("font_size", 14)
	main_box.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1.0, 24.0)
	main_box.add_child(spacer)

	var start_button := _make_menu_button("START GAME")
	start_button.pressed.connect(_start_game)
	main_box.add_child(start_button)

	var graphics_label := Label.new()
	graphics_label.text = "GRAPHICS"
	graphics_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	graphics_label.add_theme_font_size_override("font_size", 16)
	main_box.add_child(graphics_label)

	main_graphics_option = _make_graphics_option()
	main_graphics_option.item_selected.connect(_on_graphics_selected)
	main_box.add_child(main_graphics_option)

	var controls := Label.new()
	controls.text = "WASD Move   •   Mouse Look   •   E Interact   •   P Pause"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.modulate = Color(0.62, 0.63, 0.66, 1.0)
	controls.add_theme_font_size_override("font_size", 13)
	main_box.add_child(controls)

	pause_menu = _create_menu_overlay(Color(0.01, 0.012, 0.016, 0.90))
	pause_menu.name = "PauseMenu"
	pause_menu.visible = false
	hud.add_child(pause_menu)
	var pause_box := _create_menu_box(pause_menu)

	var paused_title := Label.new()
	paused_title.text = "PAUSED"
	paused_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	paused_title.add_theme_font_size_override("font_size", 38)
	pause_box.add_child(paused_title)

	var resume_button := _make_menu_button("RESUME")
	resume_button.pressed.connect(_resume_game)
	pause_box.add_child(resume_button)

	var pause_graphics_label := Label.new()
	pause_graphics_label.text = "GRAPHICS"
	pause_graphics_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_graphics_label.add_theme_font_size_override("font_size", 16)
	pause_box.add_child(pause_graphics_label)

	pause_graphics_option = _make_graphics_option()
	pause_graphics_option.item_selected.connect(_on_graphics_selected)
	pause_box.add_child(pause_graphics_option)

	var pause_help := Label.new()
	pause_help.text = "Press P again to resume"
	pause_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_help.modulate = Color(0.62, 0.63, 0.66, 1.0)
	pause_help.add_theme_font_size_override("font_size", 13)
	pause_box.add_child(pause_help)

	_sync_graphics_selectors()

func _create_menu_overlay(color: Color) -> ColorRect:
	var overlay := ColorRect.new()
	overlay.color = color
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	return overlay

func _create_menu_box(overlay: Control) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440.0, 390.0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_bottom", 36)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)
	return box

func _make_menu_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(340.0, 54.0)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _make_graphics_option() -> OptionButton:
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(340.0, 48.0)
	option.add_item("Low", 0)
	option.add_item("Medium", 1)
	option.add_item("High", 2)
	option.select(graphics_preset)
	return option

func _show_main_menu() -> void:
	game_started = false
	is_paused = false
	get_tree().paused = false
	main_menu.visible = true
	pause_menu.visible = false
	crosshair.visible = false
	prompt_label.visible = false
	pause_hint.visible = false
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _start_game() -> void:
	game_started = true
	is_paused = false
	main_menu.visible = false
	pause_menu.visible = false
	crosshair.visible = true
	prompt_label.visible = true
	pause_hint.visible = true
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _pause_game() -> void:
	if not game_started or is_paused:
		return
	is_paused = true
	get_tree().paused = true
	pause_menu.visible = true
	crosshair.visible = false
	prompt_label.visible = false
	pause_hint.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resume_game() -> void:
	if not game_started:
		return
	is_paused = false
	get_tree().paused = false
	pause_menu.visible = false
	crosshair.visible = true
	prompt_label.visible = true
	pause_hint.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_graphics_selected(index: int) -> void:
	graphics_preset = clampi(index, 0, 2)
	_apply_graphics_preset(graphics_preset)
	_sync_graphics_selectors()

func _sync_graphics_selectors() -> void:
	if is_instance_valid(main_graphics_option):
		main_graphics_option.select(graphics_preset)
	if is_instance_valid(pause_graphics_option):
		pause_graphics_option.select(graphics_preset)

func _apply_graphics_preset(preset: int) -> void:
	var viewport := get_viewport()
	match preset:
		0:
			viewport.scaling_3d_scale = 0.65
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			_set_light_shadows(self, false)
		1:
			viewport.scaling_3d_scale = 0.85
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			_set_light_shadows(self, true)
		2:
			viewport.scaling_3d_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_4X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			_set_light_shadows(self, true)

func _set_light_shadows(node: Node, enabled: bool) -> void:
	for child in node.get_children():
		if child is Light3D:
			(child as Light3D).shadow_enabled = enabled
		_set_light_shadows(child, enabled)

func _on_prompt_changed(text: String) -> void:
	if not transitioning and game_started and not is_paused:
		prompt_label.text = text

func _on_player_interacted(target: Object) -> void:
	if transitioning or escaped or is_paused or not target.has_meta("kind"):
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
	_apply_graphics_preset(graphics_preset)
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
	jungle.process_mode = Node.PROCESS_MODE_PAUSABLE
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
