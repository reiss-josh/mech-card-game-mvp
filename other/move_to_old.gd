extends Node2D

# variables for movement/scaling
var need_move := false
const _MOVE_POSITION_SPEED := 6
@onready var target_position : Vector2 = self.position
@onready var target_scale : Vector2 = self.scale
signal arrived()


## Takes [new_target_position] and [new_target_scale_factor], and sets those as targets for the card.
func move_to_old(new_target_position : Vector2, new_target_scale_factor : float = -1.0) -> void:
	target_position = new_target_position
	need_move = true
	if(new_target_scale_factor >= 0.0):
		target_scale = new_target_scale_factor * Global.CARD_START_SCALE
	else:
		target_scale = Global.CARD_START_SCALE
	#TODO: play a start-movement sound


## Lerps card from current position to target position
func move_to_helper(delta) -> void:
	# check if we're close yet
	var distance_remaining = abs((position.x + position.y) - (target_position.x + target_position.y))
	if(distance_remaining > _MOVE_POSITION_SPEED*2 * target_scale.x):
		var weight = 1 - exp(-_MOVE_POSITION_SPEED * delta)
		position = position.lerp(target_position, weight)
		scale = scale.lerp(target_scale, weight)
	# if we're almost there, square our movement speed
	elif(distance_remaining > 0.1 * target_scale.x):
		var weight = 1 - exp(-(_MOVE_POSITION_SPEED*_MOVE_POSITION_SPEED) * delta)
		position = position.lerp(target_position, weight)
		scale = scale.lerp(target_scale, weight)
	# if we've arrived, update flags and snap position
	else:
		position = target_position
		scale = target_scale
		need_move = false
		arrived.emit()
		#TODO: emit a movement-finished sound?
