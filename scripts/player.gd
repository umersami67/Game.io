extends CharacterBody3D

signal prompt_changed(text: String)
signal interacted(target: Object)

@export var walk_speed := 4.0
@export var acceleration := 14.0
@export var mouse_sensitivity := 0.0022
@export var jump_velocity := 4.2

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var _last_prompt := ""

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-82.0),
			deg_to_rad(82.0)
		)

	if event.is_action_pressed("release_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("interact"):
		_try_interact()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var local_dir := Vector3(input_vec.x, 0.0, input_vec.y)
	var direction := (transform.basis * local_dir).normalized()
	var target_x := direction.x * walk_speed
	var target_z := direction.z * walk_speed

	velocity.x = move_toward(velocity.x, target_x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_z, acceleration * delta)
	move_and_slide()
	_update_interaction_prompt()

func _update_interaction_prompt() -> void:
	var text := ""
	if interaction_ray.is_colliding():
		var collider := interaction_ray.get_collider()
		if collider and collider.has_meta("prompt"):
			text = "[E] " + str(collider.get_meta("prompt"))

	if text != _last_prompt:
		_last_prompt = text
		prompt_changed.emit(text)

func _try_interact() -> void:
	if not interaction_ray.is_colliding():
		return
	var collider := interaction_ray.get_collider()
	if collider and collider.has_meta("interactable") and bool(collider.get_meta("interactable")):
		interacted.emit(collider)

func reset_to(position_target: Vector3, yaw_degrees := 0.0) -> void:
	global_position = position_target
	rotation = Vector3(0.0, deg_to_rad(yaw_degrees), 0.0)
	head.rotation = Vector3.ZERO
	velocity = Vector3.ZERO
