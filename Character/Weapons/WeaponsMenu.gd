extends CanvasGroup

const WeaponsTypes = Weapons.WeaponTypes

signal weapons_choice(first: WeaponsTypes, second: WeaponsTypes)

@onready var FirstMelee := $FirstMelee
@onready var FirstProjectile := $FirstProjectile
@onready var Submit := $Submit

var meleeType: WeaponsTypes = WeaponsTypes.None
var projectileType: WeaponsTypes = WeaponsTypes.None

func _ready():
	FirstMelee.set_weapon_type(WeaponsTypes.Bubble)
	FirstProjectile.set_weapon_type(WeaponsTypes.Bullets)
	
	FirstMelee.connect("selected", func(type):
		meleeType = type
		update_buttons()	
	)
	FirstProjectile.connect("selected", func(type):
		projectileType = type
		update_buttons()
	)
	update_buttons()
	
func update_buttons():
	$Submit.disabled = meleeType == WeaponsTypes.None or projectileType == WeaponsTypes.None

func _on_submit_pressed():
	emit_signal("weapons_choice", meleeType, projectileType)
