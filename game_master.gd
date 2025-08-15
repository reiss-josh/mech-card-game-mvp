extends Node

## Manages the CardGame and the GridGame, interfacing the two with eachother.
## Manages the general gamestate.
## Manages multiplayer connections / enemy logic (?)

@onready var card_game = $CardGame
@onready var card_hud = $CardHud


func _ready():
	_connect_child_signals()
	
	
func _connect_child_signals():
	card_game.update_player_energy.connect(_on_update_player_energy)
	card_game.ready_for_lockin.connect(_on_lockin_update)
	card_hud._LockInButton.pressed.connect(_on_lockin_clicked)
	

#handle CardGame signalling whether or not we're ready to LOCK IN
func _on_lockin_update(ready_for_lockin : bool) -> void:
	$CardHud.get_node("LockInContainer").visible = true
	

#handle CardHud signalling that we've LOCKED IN
func _on_lockin_clicked() -> void:
	print("!!ACTION!!")
	pass



## Updates player energy global.
## Updates the hud to reflect changes.
func _on_update_player_energy(energy_change : int) -> void:
	PlayerVariables.curr_player_energy += energy_change
	$CardHud.energy_value = PlayerVariables.curr_player_energy #update the energy display
