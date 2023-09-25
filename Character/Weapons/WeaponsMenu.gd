extends CanvasGroup

const WeaponsTypes = Weapons.WeaponTypes

signal weapons_choice(first: WeaponsTypes, second: WeaponsTypes)

@onready var FirstMelee := $Melees/FirstMelee
@onready var SecondMelee := $Melees/SecondMelee
@onready var FirstProjectile := $Projectiles/FirstProjectile
@onready var SecondProjectile := $Projectiles/SecondProjectile
@onready var Submit := $Submit

var meleeType: WeaponsTypes = WeaponsTypes.None
var projectileType: WeaponsTypes = WeaponsTypes.None

func _ready():
	FirstMelee.set_weapon_type(WeaponsTypes.Bubble)
	SecondMelee.set_weapon_type(WeaponsTypes.Cross)
	FirstProjectile.set_weapon_type(WeaponsTypes.Bullets)
	SecondProjectile.set_weapon_type(WeaponsTypes.Orbit)
	
	for melee in [FirstMelee, SecondMelee]:
		melee.connect("selected", func(type):
			meleeType = type
			update_buttons()	
		)
	for projectile in [FirstProjectile, SecondProjectile]:
		projectile.connect("selected", func(type):
			projectileType = type
			update_buttons()
		)
		
	update_buttons()
	
func update_buttons():
	$Submit.disabled = meleeType == WeaponsTypes.None or projectileType == WeaponsTypes.None

func _on_submit_pressed():
	emit_signal("weapons_choice", meleeType, projectileType)
