extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var trauma_causer = $trauma_causer

@export var _weapon_resources : Array[Weapon_Resource]
@export var Start_Weapons : Array[String]

var Current_Weapon = null
var Weapon_Stack = [] # An array of weapons currently held by player
var Weapon_Indicator = 0
var Next_Weapon : String
var Weapon_List = {}

func _ready() -> void:
	Initialize(Start_Weapons) # enter the state machine

func _input(event) -> void:
	if event.is_action_pressed("switch_weapon_up"):
		Weapon_Indicator = min(Weapon_Indicator + 1, Weapon_Stack.size() - 1)
		exit(Weapon_Stack[Weapon_Indicator])
	
	if event.is_action_pressed("switch_weapon_down"):
		Weapon_Indicator = max(Weapon_Indicator - 1, 0)
		exit(Weapon_Stack[Weapon_Indicator])
	
	if event.is_action_pressed("shoot"):
		shoot()
	
	if event.is_action_pressed("reload"):
		reload()

func Initialize(_start_weapons: Array):
	# creating a dictionary to refer to our weapons
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_Name] = weapon
	
	for i in _start_weapons:
		Weapon_Stack.push_back(i) # add out start weapons
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]] # set the first weapon in the stack to current
	emit_signal("Update_Weapon_Stack", Weapon_Stack)
	enter()

func enter():
	# call when first "entering" into a weapon
	animation_player.queue(Current_Weapon.Activate_Anim)
	emit_signal("Weapon_Changed", Current_Weapon.Weapon_Name)
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])

func exit(_next_weapon: String):
	# in order to change weapons first call exit
	if _next_weapon != Current_Weapon.Weapon_Name:
		if animation_player.get_current_animation() != Current_Weapon.Deactivate_Anim:
			animation_player.play(Current_Weapon.Deactivate_Anim)
			Next_Weapon = _next_weapon

func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == Current_Weapon.Deactivate_Anim:
		Change_Weapon(Next_Weapon)
	
	if anim_name == Current_Weapon.Shoot_Anim && Current_Weapon.Auto_Fire == true:
		if Input.is_action_pressed("shoot"):
			shoot()

func shoot():
	if Current_Weapon.Current_Ammo != 0:
		if !animation_player.is_playing():
			animation_player.play(Current_Weapon.Shoot_Anim) # TODO: make an animation of shooting
			Current_Weapon.Current_Ammo -= 1
			trauma_causer.cause_trauma()
			emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	else:
		reload()

func reload():
	if Current_Weapon.Current_Ammo == Current_Weapon.Magazine:
		return
	elif !animation_player.is_playing():
		#animation_player.play(Current_Weapon.Reload_Anim) // TODO: make an animation of reloading
		var Reload_Amount = min(Current_Weapon.Magazine - Current_Weapon.Current_Ammo, Current_Weapon.Magazine, Current_Weapon.Reserve_Ammo)
		Current_Weapon.Current_Ammo = Current_Weapon.Current_Ammo + Reload_Amount
		Current_Weapon.Reserve_Ammo = Current_Weapon.Reserve_Ammo - Reload_Amount
		emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
