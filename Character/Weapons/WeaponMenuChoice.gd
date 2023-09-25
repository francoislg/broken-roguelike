extends Button

signal selected(type: WeaponTypes)

const WeaponTypes := Weapons.WeaponTypes

const labels := {
	WeaponTypes.Bubble: 'Bubble',
	WeaponTypes.Cross: 'Cross',
	WeaponTypes.Bullets: 'Bullets',
}

var currentType: WeaponTypes

func _ready():
	connect("toggled", func(picked):
		if picked:
			emit_signal("selected", currentType)
		update_label()
	)

func set_weapon_type(type: WeaponTypes):
	currentType = type
	text = labels[type]

func update_label():
	text = labels[currentType] + (" (selected)" if button_pressed else "")
