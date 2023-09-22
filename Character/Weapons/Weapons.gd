extends Node

class_name Weapons

enum WeaponTypes {
	None = -1,
	Bubble,
	Bullets
}

const MeleeWeapons = [WeaponTypes.Bubble]
const ProjectileWeapons = [WeaponTypes.Bullets]

@onready var LeftCooldown := $FloatingUI/Left
@onready var RightCooldown := $FloatingUI/Right

const allWeapons := {
	WeaponTypes.Bubble: preload("res://Character/Weapons/Bubble.tscn"),
	WeaponTypes.Bullets: preload("res://Character/Weapons/Bullets.tscn")
}

var leftWeapon: Weapon
var rightWeapon: Weapon

func init_weapon_left(weaponType: WeaponTypes):
	if leftWeapon:
		remove_child(leftWeapon)
	if weaponType != WeaponTypes.None:
		var weaponScene = allWeapons[weaponType]
		var weapon = weaponScene.instantiate()
		weapon.init(LeftCooldown)
		add_child(weapon)
		leftWeapon = weapon

func init_weapon_right(weaponType: WeaponTypes):
	if rightWeapon:
		remove_child(rightWeapon)
	if weaponType != WeaponTypes.None:
		var weaponScene = allWeapons[weaponType]
		var weapon = weaponScene.instantiate()
		weapon.init(RightCooldown)
		add_child(weapon)
		rightWeapon = weapon
	
