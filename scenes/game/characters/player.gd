extends CharacterBody3D

@export var speed = 4.3
@export var crouch_speed = 2.0
@export var accel = 16.0
@export var jump_velocity = 6.0
@export var crouch_height = 0.9
@export var crouch_transition = 14.0
@export var sensitivity = 0.16
@export var min_angle = -80
@export var max_angle = 90

@export var cam_rotation_amount = 0.15
@export var weapon_sway_amount = 5.0
@export var weapon_rotation_amount = 1.0

@onready var head = $Head
@onready var collision_shape = $CollisionShape3D
@onready var top_cast = $TopCast
@onready var weapon_holder = $Head/WeaponHolder

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2
var stand_height : float
var def_weapon_holder_pos : Vector3

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
			move_speed = crouch_speed
			crouch(delta)
		else:
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

func _input(event):
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)

func crouch(delta : float, reverse = false):
	var target_height : float = crouch_height if not reverse else stand_height
	
	collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_transition * delta)
	collision_shape.position.y = lerp(collision_shape.position.y, target_height * 0.5, crouch_transition * delta)
	head.position.y = lerp(head.position.y, target_height - 0.3, crouch_transition * delta)

func cam_tilt(input_x, delta):
	if head:
		head.rotation.z = lerp(head.rotation.z, -input_x * cam_rotation_amount, 10 * delta)
