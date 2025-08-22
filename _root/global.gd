extends Node

const CARD_START_SCALE := Vector2(0.3,0.3)
const CARD_SIZE := Vector2(CARD_START_SCALE.x*750, CARD_START_SCALE.y*1050)
const CARD_QUEUE_SCALE := 0.5
const CARD_QUEUE_ADDITIONAL_BUFFER := Vector2(10,0)

## Manages player variables (health, energy, etc)
var PlayerVariables : Dictionary = {
	"STR" : 2,
	"DEF" : 2,
	"AGL" : 2,
	"TEK" : 2,
	"max_hand_size": 5,
	"max_health": 10,
	"curr_health": 10,
	"max_energy": 5,
	"curr_energy": 5,
	"max_clicks": 3,
	"curr_clicks": 0,
	"max_ammo": 5,
	"curr_ammo": 5,
}
