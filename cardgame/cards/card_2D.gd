extends Node2D

class_name Card2D

# variables for carddata structure
var card_data_dict := {}
var debug_name = ""
var card_y_offset = -150

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
var move_position_speed = 0.1
var move_position_timer = 0
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
	move_position_timer = 0
	need_move = true
	
## Lerps card from current position to target position
func move_to_helper(delta):
	# Lerp if not there yet
	if(abs(position.x - target_position.x) > 0.001) or (abs(position.y - target_position.y) > 0.001):
		move_position_timer += move_position_speed * delta
		position = position.lerp(target_position, move_position_timer)
	# Reset variables if arrvived
	else:
		position = target_position
		need_move = false

## Highlights the card if it isn't already highlighted
func start_highlight():
	if(need_highlight == false):
		need_highlight = true
		last_z_index = z_index
		last_rotation = rotation
		rotation = 0
		z_index = 50
		scale = start_scale * highlight_scale_factor
		#position.y = card_y_offset
		#set_anchors_preset(PRESET_CENTER_BOTTOM)

## Ends highlight for the card
func end_highlight():
	need_highlight = false
	rotation = last_rotation
	scale = start_scale
	z_index = last_z_index
	position.y = 0
