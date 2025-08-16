extends CardLocation
class_name CardHand
## Manages cards held within a generic CardHand Node2D
## Can add, remove, and input-report for card_2D objects
## Any card_2D objects passed in must be preloaded with card_data

# Variables for card interaction management
var _card_interaction_queued_event = null ## input event for highest-indexed card interacted with this frame
var _card_interaction_queued_hand_position : int = -1 ## highest-position card interacted with this frame
signal card_selected(card) ## signal for card being played

func _process(delta) -> void:
	if _card_interaction_queued_event != null: #check and resolve card queue
		_resolve_card_interaction_queue.call_deferred(_card_array[_card_interaction_queued_hand_position], _card_interaction_queued_event)
	if _hide_flag >= 0:
		_show_hide_helper(delta)


## Function for rearranging screen position on _ready
func _self_positioning() -> void:
	var screen_size := get_viewport_rect().size
	position.x = screen_size.x * 1/2
	position.y = screen_size.y * .99
	_HIDE_OFFSET = Vector2(0, Global.CARD_SIZE.y) #would like to make this const, but children need to override it


## Places card in hand. If card has a last_hand_position, the card is returned to that position.
func add_card(card, insert_position : int = card.last_hand_position) -> bool:
	card.reparent(self)
	if insert_position > _card_array.size() or insert_position < 0: #if card does not have a last_hand_position, set it to match the rightmost edge of the hand
		card.last_hand_position = _card_array.size()
		_card_array.append(card)
	else:
		card.last_hand_position = insert_position  #in case card is being inserted somewhere new
		_card_array.insert(insert_position,card)
	_connect_card_signals(card)
	_rearrange_cards()
	return true


## Updates last_hand_position, and disconnects all signals	
func _card_removal_unique(card_array_position: int, ret_card : Card2D):
	ret_card.last_hand_position = card_array_position #special
	_disconnect_card_signals(ret_card) #special


## Performs the actual rearrangement
const _CARD_BUFFER := Vector2(500,40) ## distance cards should be apart from eachother in hand (in pixels)
func _rearrange_helper(card : Card2D, curr_card_index : int) -> void:
	var middle_card_index := ((_card_array.size() + 1) / 2.0) - 1.0 # get index of middle card (or index between middle two cards)
	var dist_from_center := curr_card_index - middle_card_index
	card.z_index = floor(dist_from_center)
	card.move_to(Vector2(dist_from_center * _CARD_BUFFER.x / _card_array.size(), abs(dist_from_center) * _CARD_BUFFER.y / _card_array.size()))
	card.rotation = lerpf(0, TAU/18, dist_from_center / _card_array.size())


## Connects all necessary signals from child card to this node
func _connect_card_signals(card) -> void:
	card.get_node("CardCollisionArea").input_event.connect(_on_card_input_event.bind(card))
	card.get_node("CardCollisionArea").mouse_entered.connect(_on_card_input_event.bind(null, "mouse_entered", null, card))
	card.get_node("CardCollisionArea").mouse_exited.connect(_on_card_input_event.bind(null, "mouse_exited", null, card))


## Disconnects all necessary signals from child card to this node
func _disconnect_card_signals(card) -> void:
	card.get_node("CardCollisionArea").input_event.disconnect(_on_card_input_event)
	card.get_node("CardCollisionArea").mouse_entered.disconnect(_on_card_input_event)
	card.get_node("CardCollisionArea").mouse_exited.disconnect(_on_card_input_event)


## Enqueues input events from generic 2d_input_event signals
func _on_card_input_event(_viewport, event, _shape_idx, card) -> void:
	if(is_interactable and card.need_move == false):
		_attempt_card_interaction_enqueue(card, event)


## Attempts to enqueue event from card for interaction this frame
## Compares against currently enqueued events, if any exist, to ensure the highest card in hand is preferred
## (Also handles certain special cases)
func _attempt_card_interaction_enqueue(card, event) -> void:
	# Enqueue if any of the following:
	# 	case 1: card is highest in the hand
	# 	case 2: card is tied for highest position, and event is a String (overrides clicks/mouse movements with custom events)
	var card_queue_pos = _card_array.find(card)
	if ((card_queue_pos > _card_interaction_queued_hand_position) or #case1
		((card_queue_pos == _card_interaction_queued_hand_position) and (event is String))): #case2
		_card_interaction_queued_hand_position = card_queue_pos
		_card_interaction_queued_event = event
	# if card is currently highlighted, but didn't get enqueued this frame, end the highlight.
	elif card_queue_pos != _card_interaction_queued_hand_position and card.need_highlight == true:
		card.end_highlight()


## Performs the input event associated with the card which is highest up in the hand
# card_selected signal gets emitted from here
func _resolve_card_interaction_queue(card, event) -> void:
	#handle mouse-click on card
	if event is InputEventMouseButton and event.pressed:
		card_selected.emit(card)
	#handle mouse entry/exit
	elif event is String:
		if event == "mouse_entered":
			card.start_highlight()
		elif event == "mouse_exited":
			card.end_highlight()
	#handle mouse motion
	elif event is InputEventMouseMotion:
		card.start_highlight()
	#reset the card queue variables
	_card_interaction_queued_hand_position = -1
	_card_interaction_queued_event = null


## Performs a red flash + shake if a card can't be interacted
#TODO
func fail_interaction(card) -> void:
	print("failed to play ", card.debug_name)
	pass
