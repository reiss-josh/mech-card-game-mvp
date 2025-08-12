extends Node2D

class_name Card2D

# variables for carddata structure
var card_data_dict := {}
var debug_name = ""
var card_size := Vector2(0.3*750, 0.3*1050)

## Card's last hand position, if applicable
var last_hand_position : int = -1

# variables for highlighting
var highlight_scale_factor = 1.1
var need_highlight = false
@onready var start_scale = self.scale
@onready var last_z_index = self.z_index
@onready var last_rotation = self.rotation

# variables for movement
var need_move = false
var move_position_speed = 6
@onready var target_position = self.position

# manage cardData structure
@export var data:CardData:
	set(value):
		var card_template = $"CardViewport/CardTemplate"
		data = value
		# check if we actually received any data
		if(data != null):
			# check if we've ever saved data for this card before
			if (card_data_dict.is_empty()):
				# find references and save
				card_data_dict["Name"] = card_template.find_child("Name")
				card_data_dict["Cost"] = card_template.find_child("Cost")
				card_data_dict["CardBody"] = card_template.find_child("CardBody")
				card_data_dict["CardType"] = card_template.find_child("CardType")
			# save to existing references
			card_data_dict["Name"].text = data.card_name
			card_data_dict["Cost"].text = str(data.card_cost)
			card_data_dict["CardBody"].text = data.card_body
			card_data_dict["CardType"].text = data.card_type
			debug_name = data.card_name

#TODO: there must be a better way
func _process(delta):
	if(need_move):
		move_to_helper(delta)

## Takes a position and sets that as card's new target position
func move_to(new_target_position):
	target_position = new_target_position
	need_move = true
	
## Lerps card from current position to target position
func move_to_helper(delta):
	# check if we're close yet
	var distance_remaining = abs((position.x + position.y) - (target_position.x + target_position.y))
	if(distance_remaining > move_position_speed*2):
		var weight = 1 - exp(-move_position_speed * delta)
		position = position.lerp(target_position, weight)
	# if we're almost there, square our movement speed
	elif(distance_remaining > 0.1):
		var weight = 1 - exp(-(move_position_speed*move_position_speed) * delta)
		position = position.lerp(target_position, weight)
	# if we've arrived, update our move flag
	else:
		position = target_position
		need_move = false

## Highlights the card if it isn't already highlighted
func start_highlight():
	if(need_highlight == false):
		#save variables
		need_highlight = true
		last_z_index = z_index
		last_rotation = rotation
		#set new visuals
		z_index = 50
		rotation = 0
		scale = start_scale * highlight_scale_factor
		position.y = -(1+ card_size.y/2)

## Ends highlight for the card
func end_highlight():
	#save variables
	need_highlight = false
	#reset visuals
	z_index = last_z_index
	rotation = last_rotation
	scale = start_scale
	position.y = 0
