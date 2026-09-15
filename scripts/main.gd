extends Node3D

const APARTMENT_SCRIPT := preload("res://scripts/apartment.gd")
const PLAYER_START := Vector3(0.0, 1.0, 2.2)

@onready var player: CharacterBody3D = $Player
@onready var prompt_label: Label = $HUD/Prompt

var apartment: Node3D
var current_loop := 1
var door_attempts := 0
var mirror_engaged := false
var transitioning := false

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
	if transitioning or not target.has_meta("kind"):
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
		prompt_label.text = "The lock moves... but the door stays shut."

	await get_tree().create_timer(1.45).timeout
	if current_loop < 5:
		_advance_loop()
	else:
		transitioning = false
		prompt_label.text = ""

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
