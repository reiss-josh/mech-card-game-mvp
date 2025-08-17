extends Control
class_name CardHud

@onready var _EnergyValue = self.get_node("EnergyContainer/EnergyValue")
@export var LockInButton : Button
@export var EnergyButton : Button
@export var DrawButton : Button


var energy_value : int :
	get:
		return int(_EnergyValue.text)
	set(value):
		_EnergyValue.text = str(value)


func _ready() -> void:
	prepare_hud()


## Set text variables, rearrange the hud elements
func prepare_hud() -> void:
	energy_value = PlayerVariables.curr_player_energy
	$QueueContainer.size.x = (
		Global.CARD_SIZE.x * PlayerVariables.max_player_clicks * Global.CARD_QUEUE_SCALE) + (
		Global.CARD_QUEUE_ADDITIONAL_BUFFER.x * (PlayerVariables.max_player_clicks - 1)
	)
	$QueueContainer.position.x = (get_viewport_rect().size.x / 2) - ($QueueContainer.size.x / 2)
