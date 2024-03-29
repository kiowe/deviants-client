extends Area3D

@export var trauma_reduction_rate = 4.0

@export var max_x = 12.0
@export var max_y = 3.0
@export var max_z = 3.0

@export var noise : FastNoiseLite
@export var noise_speed = 50.0

var trauma = 0.0
var time = 0.0

@onready var camera : Camera3D = $Camera3D 
@onready var initial_rotation : Vector3 = camera.rotation_degrees

func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	camera.rotation_degrees.x = lerp(camera.rotation_degrees.x, abs(initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)), 0.5)
	camera.rotation_degrees.y = lerp(camera.rotation_degrees.y, initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1), 0.5)
	camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2), 0.5)

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
