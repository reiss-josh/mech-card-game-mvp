extends Control

@onready var _EnergyValue = self.get_node("EnergyContainer/EnergyValue")
@onready var _LockInButton = self.get_node("LockInContainer/LOCKIN")


var energy_value : int :
	get:
		return int(_EnergyValue.text)
	set(value):
		_EnergyValue.text = str(value)


func _ready() -> void:
	prepare_hud()
	
	
func prepare_hud() -> void:
	energy_value = PlayerVariables.curr_player_energy
