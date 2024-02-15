extends CharacterBody3D

@export var speed = 3.6
@export var crouch_speed = 1.7
@export var accel = 16.0
@export var jump_velocity = 6.0
@export var crouch_height = 0.9
@export var crouch_transition = 14.0
@export var sensitivity = 0.16
@export var min_angle = -80
@export var max_angle = 90

@export var cam_rotation_amount = 0.06
@export var weapon_sway_amount = 0.1
@export var weapon_rotation_amount = 0.003
@export var bob_amount = 0.008
@export var bob_freq = 0.012

@onready var head = $Head
@onready var collision_shape = $CollisionShape3D
@onready var top_cast = $TopCast
@onready var weapon_holder = $Head/WeaponHolder

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2
var stand_height : float
var def_weapon_holder_pos : Vector3
var mouse_input : Vector2


func _ready():
	stand_height = collision_shape.shape.height
	def_weapon_holder_pos = weapon_holder.position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var move_speed = speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		elif Input.is_action_pressed("crouch") or top_cast.is_colliding():
			cam_rotation_amount = 0.03
			weapon_sway_amount = 0.05
			weapon_rotation_amount = 0.001
			bob_amount = 0.004
			bob_freq = 0.008
			move_speed = crouch_speed
			crouch(delta)
		else:
			cam_rotation_amount = 0.06
			weapon_sway_amount = 0.1
			weapon_rotation_amount = 0.003
			bob_amount = 0.008
			bob_freq = 0.012
			crouch(delta, true)

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * move_speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * move_speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)

	move_and_slide()
	
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y
	cam_tilt(input_dir.x, delta)
	weapon_tilt(input_dir.x, delta)
	weapon_sway(delta)
	weapon_bob(velocity.length(), delta)

func _input(event):
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)
		mouse_input = event.relative

func crouch(delta : float, reverse = false):
	var target_height : float = crouch_height if not reverse else stand_height
	
	collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_transition * delta)
	collision_shape.position.y = lerp(collision_shape.position.y, target_height * 0.5, crouch_transition * delta)
	head.position.y = lerp(head.position.y, target_height - 0.3, crouch_transition * delta)

func cam_tilt(input_x, delta):
	if head:
		head.rotation.z = lerp(head.rotation.z, -input_x * cam_rotation_amount, 10 * delta)

func weapon_tilt(input_x, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * weapon_rotation_amount * 12, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input, Vector2.ZERO, 10 * delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_rotation_amount, 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_rotation_amount, 10 * delta)

func weapon_bob(vel : int, delta):
	if weapon_holder:
		if vel > 0 and is_on_floor():
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
		else:
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10 * delta)
