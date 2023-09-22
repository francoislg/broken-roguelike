extends Node

class_name Weapon

@onready var Character := $"../../"
@onready var CharacterStats := $"../../CharacterStats"
@onready var EnemiesTracker := $"../../EnemiesTracker"
@onready var ProjectileSpawner := $"../../ProjectileSpawner"
@onready var playerVariables = CharacterStats.playerVariables

var Cooldown: CooldownUI

func init(cooldown: CooldownUI):
	Cooldown = cooldown
