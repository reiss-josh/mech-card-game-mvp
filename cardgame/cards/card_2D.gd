extends Node2D

class_name Card2D

var child_dict := {}
var debug_name = ""

var last_hand_position = null

var need_highlight = false
@onready var start_scale = self.scale
@onready var last_z_index = self.z_index
var highlight_scale_factor = 1.1

var need_move = false
var move_position_speed = 0.1
var move_position_timer = 0
@onready var target_position = self.position

#signal area_2d_input_event(event, shape_idx)

#manage cardData structure
@export var data:CardData:
	set(value):
		var card_template = $"CardViewport/CardTemplate"
		data = value
		#check if we actually received any data
		if(data != null):
			#check if we've ever saved data for this card before
			if (child_dict.is_empty()):
				#find references and save
				child_dict["Name"] = card_template.find_child("Name")
				child_dict["Cost"] = card_template.find_child("Cost")
				child_dict["CardBody"] = card_template.find_child("CardBody")
				child_dict["CardType"] = card_template.find_child("CardType")
			#save to existing references
			child_dict["Name"].text = data.card_name
			child_dict["Cost"].text = str(data.card_cost)
			child_dict["CardBody"].text = data.card_body
			child_dict["CardType"].text = data.card_type
			debug_name = data.card_name

#there must be a better way
func _process(delta):
	if(need_move):
		move_to_helper(delta)

func move_to(new_target_position):
	target_position = new_target_position
	move_position_timer = 0
	need_move = true
	
func move_to_helper(delta):
	if(!position.is_equal_approx(target_position)):
		move_position_timer += move_position_speed * delta
		position = position.lerp(target_position, move_position_timer)
	else:
		move_position_timer = 1
		position = position.lerp(target_position, move_position_timer)
		need_move = false

func start_highlight():
	if(need_highlight == false):
		need_highlight = true
		last_z_index = z_index
		scale = start_scale * highlight_scale_factor
		z_index = 50
		#print("start")
	pass
	
func end_highlight():
	need_highlight = false
	scale = start_scale / highlight_scale_factor
	z_index = last_z_index
	#print("end")
	pass
