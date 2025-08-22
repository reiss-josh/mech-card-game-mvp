extends Resource
class_name CardData

@export var card_name:String
@export var card_energy_cost:int
@export var card_type:String
@export var card_subtype:String
@export var card_value:int
@export var card_cannot_undo:bool
#variables for play area
@export var card_is_persistent:bool			## Whether card can be played
@export var card_is_clickable:bool			## Whether card can be clicked
@export var card_is_repeat_clickable:bool	## Whether card can be repeatedly clicked
@export var card_is_turn_start:bool			## Whether card triggers effect on turn start
#variables for loading
@export var card_is_loadable:bool 			## Whether card can be loaded
@export var card_loads_on_click:bool		## Whether card loads on click
@export var card_unloads_on_click:bool		## Whether card unloads on click
@export var card_loads_on_start:bool		## Whether card loads on turn start
@export var card_unloads_on_start:bool		## Whether card unloads on turn start
@export var card_load_start_value:int		## How much card starts loaded with
@export var card_load_increment:int			## How much card can be loaded by each time
@export var card_unload_increment:int		## How much the card is unloaded by each time
@export var card_load_type:String			## What the card is loaded with (e.g. "Energy")
@export var card_discards_when_empty:bool	## Whether card discards once empty
#variables for moving
@export var card_can_turn_before:bool		## Whether card lets player turn before activating in Action phase
@export var card_can_turn_after:bool		## Whether card lets player turn after activating in Action phase
#variables for attack/defend/move
@export var card_pattern:String				## Pattern for attack/defense

@export_multiline var card_body:String
