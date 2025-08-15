extends Node2D
class_name Card2D

# variables for carddata structure
var card_data := {}
var debug_name := ""
#const CARD_SIZE := Vector2(0.3*750, 0.3*1050)
# Card's last hand position, if applicable
var last_hand_position : int = -1
# variables for highlighting
const _HIGHLIGHT_SCALE_FACTOR := 1.1
const _HIGHLIGHT_Z_INDEX := 50
var need_highlight = false
@onready var last_rotation := self.rotation
@onready var start_scale : Vector2 = self.scale
@onready var last_z_index : int = self.z_index
# variables for movement/scaling
var need_move := false
const _MOVE_POSITION_SPEED := 6
@onready var target_position : Vector2 = self.position
@onready var target_scale : Vector2 = self.scale
signal arrived()


# manage cardData structure
@export var data:CardData:
	set(value):
		var card_template = $"CardViewport/CardTemplate"
		data = value
		# check if we actually received any data
		if(data != null):
			# check if we've ever saved data for this card before
			if (card_data.is_empty()):
				# find references and save
				card_data["Name"] = card_template.find_child("Name")
				card_data["EnergyCost"] = card_template.find_child("EnergyCost")
				card_data["CardBody"] = card_template.find_child("CardBody")
				card_data["CardType"] = card_template.find_child("CardType")
			# save to existing references
			card_data["Name"].text = data.card_name
			card_data["EnergyCost"].text = str(data.card_energy_cost)
			card_data["CardBody"].text = data.card_body
			card_data["CardType"].text = data.card_type
			debug_name = data.card_name


func _process(delta) -> void:
	if(need_move):
		move_to_helper(delta)


## Takes a position and sets that as card's new target position
func move_to(new_target_position : Vector2, new_target_scale : float = -1.0) -> void:
	target_position = new_target_position
	need_move = true
	if(new_target_scale >= 0.0):
		target_scale = new_target_scale * start_scale
	else:
		target_scale = start_scale
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


## Highlights the card if it isn't already highlighted
func start_highlight() -> void:
	if(need_highlight == true):
		return
	#store variables
	need_highlight = true
	last_z_index = z_index
	last_rotation = rotation
	#set new visuals
	var newTransform := Transform2D (
		0, #rotation
		start_scale * _HIGHLIGHT_SCALE_FACTOR, #scale
		self.skew, #skew
		Vector2(self.position.x, -(1 + Global.CARD_SIZE.y/2)) #position
	)
	_update_appearance(newTransform, _HIGHLIGHT_Z_INDEX)


## Ends highlight for the card
func end_highlight() -> void:
	#store variables
	need_highlight = false
	#reset visuals
	_update_appearance(Transform2D (last_rotation, start_scale, self.skew, Vector2(self.position.x, 0)), last_z_index)


## Updates appearance (helper for highlight functions above)
func _update_appearance(new_transform : Transform2D, new_z_index : int) -> void:
	self.transform = new_transform
	self.z_index = new_z_index
