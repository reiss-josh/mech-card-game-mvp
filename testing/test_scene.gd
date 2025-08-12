extends Node2D

var card_buffer = Vector2(500,40)
var card_angling = TAU/6

func _ready():
	var card_array = find_children("*", "Card2D")
	var curr_hand_size := card_array.size() # store current hand size
	var middle_card_index := ((curr_hand_size+1)/2.0) -1.0 # get index of middle card (or index between middle two cards)
	var dist_from_center := 0.0 # holder for later
	for curr_card_index in curr_hand_size:
		var curr_card = card_array[curr_card_index] # save our current card
		dist_from_center = curr_card_index - middle_card_index # determine our index distance from the middle card
		curr_card.z_index = floor(dist_from_center)
		curr_card.move_to(Vector2(dist_from_center * (card_buffer.x/curr_hand_size), abs(dist_from_center)*(card_buffer.y / curr_hand_size)))
		curr_card.rotation = lerpf(0, TAU/18, dist_from_center/curr_hand_size)
		
	print(lerpf(0,TAU/6, 0))
	print(lerpf(0,TAU/4, 1))
	print(lerpf(0,TAU/4, -1))
