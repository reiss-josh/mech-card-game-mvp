extends Node2D
class_name CardLocation
## Manages cards held within a card_array
## Can create, add, remove, and rearrange cards
## Any card_2D objects passed in must be preloaded with card_data
## When creating a CardLocation class overload the _self_positioning(), _card_removal_unique(), and _rearrange_helper() methods

#variables for card array
var _card_array : Array[Card2D] = [] ## Array of cards in hand
var _card_prefab := load("res://cardgame/cards/card_2D.tscn") ##Prefab for card_2D
#variables for show/hide
var _hide_flag := -1
var _HIDE_OFFSET = Vector2.ZERO #would like to make this const, but children need to override it
const _SHOW_HIDE_SPEED = 5
@onready var _SHOW_POSITION = self.position
# Variables for card interaction management
var _is_interactable_type := false ## Whether location is capable of responding to input
var is_interactable := false ## Whether location should currently respond to input
var _card_interaction_queued_event = null ## input event for highest-indexed card interacted with this frame
var _card_interaction_queued_location_position : int = -1 ## highest-position card interacted with this frame

# card array externals
## Public property for _card_array.size().
# Exists mostly to discourage external direct access of _card_array
var card_array_size : int:
	get:
		return _card_array.size()
## Public property for whether location can fit more cards. Always returns false by default.
## {OVERLOAD}
var card_array_isfull : bool:
	get:
		return _card_array_isfull_helper()


## Perform custom setup, set interactable, set _SHOW_POSITION, set position with _HIDE_OFFSET
func _ready() -> void:
	_self_setup()
	is_interactable = _is_interactable_type
	_SHOW_POSITION = self.position
	self.position = _SHOW_POSITION + _HIDE_OFFSET #set to hidden by default


## Perform interactions, perform show/hide animation
func _process(delta) -> void:
	if is_interactable and _card_interaction_queued_event != null: #check and resolve card queue
		_resolve_card_interaction_queue.call_deferred(_card_array[_card_interaction_queued_location_position], _card_interaction_queued_event)
	if _hide_flag >= 0:
		_show_hide_helper(delta)


## Function for rearranging screen position on _ready
## {OVERLOAD}
func _self_setup() -> void:
	pass


## Function for determining whether location can fit more cards
## {OVERLOAD}
# Exists to be overridden by card_queue
func _card_array_isfull_helper() -> bool:
	return false


## Creates deck from decklist at [deck_name].json
func create_from_decklist(deck_name : String) -> void:
	var card_data_array = DeckListManager.load_deck_json(deck_name)
	for card_data in card_data_array:
		create_card(card_data)
	shuffle_location()


## Creates new card from given [data], and places at top of the location. Returns the card.
func create_card(data) -> Card2D:
	var card : Card2D = _card_prefab.instantiate()
	card.data = data
	add_child(card)
	add_card(card)
	return card


## Adds [card] to top of location (or specified [insert_position])
func add_card(card, insert_position: int = -1) -> bool:
	if(self.card_array_isfull):
		return false
	card.reparent(self)
	if insert_position > _card_array.size() or insert_position < 0:
		_card_array.append(card)
	else:
		_card_array.insert(insert_position,card) #insert the card into _card_array at position
	_card_addition_unique(insert_position, card)
	_rearrange_cards()
	return true


## Draws a card at [card_array_position] and returns it
func draw_card(card_array_position : int = -1) -> Card2D:
	if _card_array.is_empty() or card_array_position > card_array_size:
		return
	var ret_card : Card2D
	if (card_array_position < 0): #if no position passed
		ret_card = _card_array.pop_back()
	else: #if position passed
		ret_card = _card_array[card_array_position]
		_card_array.remove_at(card_array_position)
	_card_removal_unique(card_array_position, ret_card) #for hand management ... is this clumsy code?
	if(ret_card.need_highlight): #if card is highlighted, un-highlight it
		ret_card.end_highlight()
	_rearrange_cards()
	return ret_card


## Removes [card] from location at passed position.
func draw_specific_card(card : Card2D) -> Card2D:
	if _card_array.size() <= 0:
		return
	var ret_card_ind = _card_array.find(card)
	if ret_card_ind is int and ret_card_ind > -1:
		return draw_card(ret_card_ind)
	else:
		return


## Special function to be overrloaded by special methods for children on card addition
## {OVERLOAD}
func _card_addition_unique(_card_array_position: int, _card : Card2D) -> void:
	pass


## Special function to be overrloaded by special methods for children on card removal
## {OVERLOAD}
func _card_removal_unique(_card_array_position: int, _card : Card2D) -> void:
	pass


## Rearranges cards on the screen
func _rearrange_cards() -> void:
	for curr_card_index in _card_array.size():
		_rearrange_helper(_card_array[curr_card_index], curr_card_index)
	#TODO: emit a rearrangement sound (maybe should be in _rearrange_helper, actually??)


## Performs the actual rearrangement of each [card] at [curr_card_index]
## {OVERLOAD}
func _rearrange_helper(_card : Card2D, _curr_card_index : int) -> void:
	pass


## Shuffles all the cards in a location
func shuffle_location() -> void:
	_card_array.shuffle()


## Moves location offscreen
func hide_location() -> void:
	_hide_flag = 1
	is_interactable = false
	#TODO: play a start-movement sound


## Moves location onscreen
func show_location() -> void:
	_hide_flag = 0
	is_interactable = _is_interactable_type
	#TODO: play a start-movement sound
	
	
## Performs screen hide/show
func _show_hide_helper(delta) -> void:
	if(_hide_flag < 0):
		return
	var target_position = _SHOW_POSITION
	if(_hide_flag == 1):
		target_position = target_position + _HIDE_OFFSET
	# check if we're close yet
	var distance_remaining = abs((position.x + position.y) - (target_position.x + target_position.y))
	if(distance_remaining > _SHOW_HIDE_SPEED*2):
		var weight = 1 - exp(-_SHOW_HIDE_SPEED * delta)
		position = position.lerp(target_position, weight)
	# if we're almost there, square our movement speed
	elif(distance_remaining > 0.1):
		var weight = 1 - exp(-(_SHOW_HIDE_SPEED*_SHOW_HIDE_SPEED) * delta)
		position = position.lerp(target_position, weight)
	# if we've arrived, update flags and snap position
	else:
		position = target_position
		_hide_flag = -1
		#TODO: emit a movement-finished sound?


## Enqueues input events from generic 2d_input_event signals
func _on_card_input_event(_viewport, event, _shape_idx, card : Card2D) -> void:
	if(is_interactable and card.need_move == false):
		_attempt_card_interaction_enqueue(card, event)


## Attempts to enqueue event from card for interaction this frame
## Compares against currently enqueued events, if any exist, to ensure the highest card in hand is preferred
## (Also handles certain special cases)
func _attempt_card_interaction_enqueue(card : Card2D, event) -> void:
	# Enqueue if any of the following:
	# 	case 1: card is highest in the location
	# 	case 2: card is tied for highest position, and event is a String (overrides clicks/mouse movements with custom events)
	var card_queue_pos = _card_array.find(card)
	if ((card_queue_pos > _card_interaction_queued_location_position) or #case1
		((card_queue_pos == _card_interaction_queued_location_position) and (event is String))): #case2
		_card_interaction_queued_location_position = card_queue_pos
		_card_interaction_queued_event = event
	# if card is currently highlighted, but didn't get enqueued this frame, end the highlight.
	elif card_queue_pos != _card_interaction_queued_location_position and card.need_highlight == true:
		card.end_highlight()


## Performs the input event associated with the card which is highest up in the location
## {OVERRIDE}
func _resolve_card_interaction_queue(_card : Card2D, _event) -> void:
	pass
