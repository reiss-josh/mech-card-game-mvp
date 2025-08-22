extends CanvasLayer
class_name CardHud

@onready var _HealthValue : Label = self.find_child("HealthValue")
@onready var _ClickValue : Label  = self.find_child("ClickValue")
@onready var _EnergyValue : Label = self.find_child("EnergyValue")
@onready var _AmmoValue : Label = self.find_child("AmmoValue")
@export var LockInButton : Button
@export var EnergyButton : Button
@export var DrawButton : Button
@export var ActionButtons : Container

func _ready() -> void:
	prepare_hud()


## Set text variables, rearrange the hud elements
func prepare_hud() -> void:
	update_hud()
	$QueueContainer.size.x = (
		Global.CARD_SIZE.x * Global.PlayerVariables["max_clicks"] * Global.CARD_QUEUE_SCALE) + (
		Global.CARD_QUEUE_ADDITIONAL_BUFFER.x * (Global.PlayerVariables["max_clicks"] - 1)
	)
	$QueueContainer.position.x = (get_viewport().get_visible_rect().size.x / 2) - ($QueueContainer.size.x / 2)


func update_hud() -> void:
	_EnergyValue.text = str(Global.PlayerVariables["curr_energy"])
	_ClickValue.text = str(Global.PlayerVariables["curr_clicks"])
	_AmmoValue.text = str(Global.PlayerVariables["curr_ammo"])
	_HealthValue.text = str(Global.PlayerVariables["curr_health"])
