extends RigidBody2D

@onready var attackDamageArea := $AttackDamageArea

var damage: float

func _on_attack_range_area_body_entered(_node):
	if not is_queued_for_deletion():
		var enemies = attackDamageArea.get_overlapping_bodies().filter(func (body): return body is BaseEnemy)
		for enemy in enemies:
			enemy.receive_damage(linear_velocity.normalized(), damage)

		queue_free()
