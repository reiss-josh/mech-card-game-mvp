extends Node

## Manages the CardGame and the GridGame, interfacing the two with eachother.
## Manages the general gamestate.
## Manages multiplayer connections / enemy logic (?)

@onready var card_game = $CardGame


func _ready():
	_connect_child_signals()
	

func _connect_child_signals():
	card_game.locked_in.connect(_on_card_game_locked_in)


func _on_card_game_locked_in(queue_array) -> void:
	print("The following cards have been queued:")
	for i in queue_array:
		print(i.debug_name)
	pass
