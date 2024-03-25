extends CanvasLayer

@onready var current_weapon: Label = $VBoxContainer/HBoxContainer/CurrentWeapon
@onready var current_ammo: Label = $VBoxContainer/HBoxContainer2/CurrentAmmo
@onready var current_weapon_stack: Label = $VBoxContainer/HBoxContainer3/CurrentWeaponStack


func _on_weapon_holder_update_ammo(ammo) -> void:
	current_ammo.set_text(str(ammo[0]) + " / " + str(ammo[1])) # [CurrentAmmo / ReserveAmmo]


func _on_weapon_holder_update_weapon_stack(weapon_stack) -> void:
	current_weapon_stack.set_text("")
	for i in weapon_stack:
		current_weapon_stack.text += "\n" + i


func _on_weapon_holder_weapon_changed(weapon_name) -> void:
	current_weapon.set_text(weapon_name)
