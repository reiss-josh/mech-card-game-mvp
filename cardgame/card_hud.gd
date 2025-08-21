extends CanvasLayer
class_name CardHud

@export var _ClickValue : Label 
@export var _EnergyValue : Label
@export var LockInButton : Button
@export var EnergyButton : Button
@export var DrawButton : Button
@export var ActionButtons : Container


var energy_value : int :
	get:
		return int(_EnergyValue.text)
	set(value):
		_EnergyValue.text = str(value)

var click_value : int :
	get:
		return int(_ClickValue.text)
	set(value):
		_ClickValue.text = str(value)


func _ready() -> void:
	prepare_hud()


## Set text variables, rearrange the hud elements
func prepare_hud() -> void:
	energy_value = PlayerVariables.curr_player_energy
	click_value = PlayerVariables.curr_player_clicks
	$QueueContainer.size.x = (
		Global.CARD_SIZE.x * PlayerVariables.max_player_clicks * Global.CARD_QUEUE_SCALE) + (
		Global.CARD_QUEUE_ADDITIONAL_BUFFER.x * (PlayerVariables.max_player_clicks - 1)
	)
	#print(get_final_transform())
	$QueueContainer.position.x = (get_viewport().get_visible_rect().size.x / 2) - ($QueueContainer.size.x / 2)
