extends Node2D

class_name Card2D

var child_dict := {}
var debug_name = ""

var hand_position := 0
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
