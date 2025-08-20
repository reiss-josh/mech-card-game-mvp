extends Resource
class_name CardData

@export var card_name:String
@export var card_energy_cost:int
@export var card_type:String
@export var card_value:int
#variables for play area
@export var card_is_persistent:bool ## Whether card can be played
@export var card_is_clickable:bool ## Whether card can be clicked
@export var card_is_repeat_clickable:bool ## Whether card can be repeatedly clicked
@export var card_is_turn_start:bool ## Whether card triggers effect on turn start
#variables for loading
@export var card_is_loadable:bool ## Whether card can be loaded
@export var card_loads_on_play:bool ## Whether card loads automatically on play
@export var card_load_start_value:int ## How much card starts loaded with
@export var card_load_increment:int ## How much card can be loaded by each time
@export var card_unload_increment:int ## How much the card is unloaded by each time
@export var card_load_type:String ## What the card is loaded with (e.g. "Energy")

@export_multiline var card_body:String
