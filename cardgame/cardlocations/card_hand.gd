extends CardLocation
class_name CardHand
## Manages cards held within a generic CardHand Node2D
## Can add, remove, and input-report for card_2D objects
## Any card_2D objects passed in must be preloaded with card_data

# Variables for card interaction management
signal card_selected(card : Card2D) ## signal for card being played


## Function for rearranging screen position on _ready
func _self_setup() -> void:
	var screen_size := get_viewport_rect().size
	position.x = screen_size.x * 1/2
	position.y = screen_size.y
	_HIDE_OFFSET = Vector2(0, Global.CARD_SIZE.y) #would like to make this const, but children need to override it
	_is_interactable_type = true


## Adds [card] to top of location (or specified [insert_position]). returns true on succes
func add_card(card : Card2D, insert_position: int = -1) -> bool:
	if(self.card_array_isfull):
		return false
	card.reparent(self)
	if (!card.last_hand_position < 0) and (card.last_hand_position < _card_array.size()):
		insert_position = card.last_hand_position
	if insert_position > _card_array.size() or insert_position < 0:
		_card_array.append(card)
		card.last_hand_position = _card_array.size()
	else:
		card.last_hand_position = insert_position  #in case card is being inserted somewhere new
		_card_array.insert(insert_position,card) #insert the card into _card_array at position
	_card_addition_unique(insert_position, card) #special for necessary signal hookups
	_rearrange_cards()
	return true


## Performs the actual rearrangement
## {OVERRIDE}
const _CARD_BUFFER := Vector2(500,40) ## distance cards should be apart from eachother in hand (in pixels)
func _rearrange_helper(card : Card2D, curr_card_index : int) -> void:
	var middle_card_index := ((_card_array.size() + 1) / 2.0) - 1.0 # get index of middle card (or index between middle two cards)
	var dist_from_center := curr_card_index - middle_card_index
	card.z_index = floor(dist_from_center)
	card.move_and_scale(Vector2(dist_from_center * _CARD_BUFFER.x / _card_array.size(), abs(dist_from_center) * _CARD_BUFFER.y / _card_array.size()))
	card.rotation = lerpf(0, TAU/18, dist_from_center / _card_array.size())


## Update last_hand_position, connect signals
## {OVERRIDE}
const HAND_HIGHLIGHT_FACTOR = 1.1
const HAND_HIGHLIGHT_Y_OFFSET = -(Global.CARD_SIZE.y * HAND_HIGHLIGHT_FACTOR/2)
func _card_addition_unique(_insert_position : int, card: Card2D) -> void:
	card.get_node("CardCollisionArea").input_event.connect(_on_card_input_event.bind(card))
	card.get_node("CardCollisionArea").mouse_entered.connect(_on_card_input_event.bind(null, "mouse_entered", null, card))
	card.get_node("CardCollisionArea").mouse_exited.connect(_on_card_input_event.bind(null, "mouse_exited", null, card))
	card.update_highlight_transform(HAND_HIGHLIGHT_FACTOR, HAND_HIGHLIGHT_Y_OFFSET)


## Updates last_hand_position, disconnect signals
## {OVERRIDE}
func _card_removal_unique(card_array_position : int, card : Card2D):
	card.last_hand_position = card_array_position #special
	card.get_node("CardCollisionArea").input_event.disconnect(_on_card_input_event)
	card.get_node("CardCollisionArea").mouse_entered.disconnect(_on_card_input_event)
	card.get_node("CardCollisionArea").mouse_exited.disconnect(_on_card_input_event)


## Performs the input event associated with the card which is highest up in the location
## {OVERRIDE}
# card_selected signal gets emitted from here
func _resolve_card_interaction_queue(card : Card2D, event) -> void:
	#handle mouse-click on card
	if event is InputEventMouseButton and event.pressed:
		card_selected.emit(card)
	#handle mouse entry/exit
	elif event is String:
		if event == "mouse_entered":
			self.start_highlight(card)
		elif event == "mouse_exited":
			card.end_highlight()
	#handle mouse motion
	elif event is InputEventMouseMotion:
		self.start_highlight(card)
	#reset the card queue variables
	_card_interaction_queued_location_position = -1
	_card_interaction_queued_event = null


## Performs a red flash + shake if a card can't be interacted
#TODO
func fail_interaction(card : Card2D) -> void:
	print("failed to play ", card.debug_name)
	pass
