extends Node

class_name CoinStage

signal stage_win

@onready var Coins := $"../../Coins"
@onready var StageLabel := $"../../UI/StageLabel"

var numberOfCoins := 0

func do_ready():
	for coin in Coins.get_children().filter(func(c): return c is Coin):
		numberOfCoins += 1
		coin.connect("picked_up", on_coin_picked_up)
	updateLabel()

func do_process(_delta):
	pass

func on_coin_picked_up():
	numberOfCoins -= 1
	
	updateLabel()
	
	if numberOfCoins <= 0:
		emit_signal('stage_win')

func updateLabel():
	StageLabel.text = "Coins Left: %s" % numberOfCoins
