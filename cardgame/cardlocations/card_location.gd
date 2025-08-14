extends Node2D
class_name CardLocation
## Manages cards held within a card_array
## Can create, add, remove, and rearrange cards
## Any card_2D objects passed in must be preloaded with card_data
## When creating a CardLocation class overload the _self_positioning(), _card_removal_unique(), and _rearrange_helper() methods

var _card_array : Array[Card2D] = [] ## Array of cards in hand
var _card_prefab := load("res://cardgame/cards/card_2D.tscn") ##Prefab for card_2D
const CARD_SIZE := Vector2(0.3*750, 0.3*1050)
var is_interactable := true ## Whether hand should respond to input

var card_array_size : int: # Public property for _card_array.size(). Exists mostly to discourage external direct access of _card_array
	get:
		return _card_array.size()
var card_array_isfull : bool: # Public property for whether location can fit more cards. Always returns false by default.
	get:
		return _card_array_isfull_helper()


func _ready() -> void:
	is_interactable = true
	_self_positioning()


## Function for rearranging screen position on _ready
## {OVERLOAD}
func _self_positioning() -> void:
	pass


## Function for determining whether location can fit more cards
## {OVERLOAD}
# Exists to be overridden by card_queue
func _card_array_isfull_helper() -> bool:
	return false


## Creates new card from given data, and places at top of the deck
func create_card(data) -> void:
	var card : Card2D = _card_prefab.instantiate()
	card.data = data
	add_child(card)
	add_card(card)


## Adds card to top of deck (or specified position)
func add_card(card, insert_position: int = -1) -> bool:
	if(self.card_array_isfull):
		return false
	card.reparent(self)
	card.scale = card.start_scale * 1
	if insert_position > _card_array.size() or insert_position < 0:
		_card_array.append(card)
	else:
		_card_array.insert(insert_position,card) #insert the card into _card_array at position
	_rearrange_cards()
	return true


## Draws a card from the top of the deck and returns it
func draw_card_old() -> Card2D:
	if _card_array.is_empty():
		return
	var ret_card = _card_array.pop_back()
	_rearrange_cards()
	return ret_card
	
	
## Draws a card from the top of the deck and returns it
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
	ret_card.end_highlight()
	_rearrange_cards()
	return ret_card


## Removes card from hand at passed position.
func draw_specific_card(card : Card2D) -> Card2D:
	if _card_array.size() <= 0:
		return
	var ret_card_ind = _card_array.find(card)
	if ret_card_ind is int and ret_card_ind > -1:
		return draw_card(ret_card_ind)
	else:
		return


## Special function to be overrloaded by special methods for children on card removal
## {OVERLOAD}
func _card_removal_unique(card_array_position: int, ret_card : Card2D):
	pass


## Rearranges cards on the screen
func _rearrange_cards() -> void:
	for curr_card_index in _card_array.size():
		_rearrange_helper(_card_array[curr_card_index], curr_card_index)
	#TODO: emit a rearrangement sound (maybe should be in _rearrange_helper, actually??)


## Performs the actual rearrangement
## {OVERLOAD}
func _rearrange_helper(_card : Card2D, _curr_card_index : int) -> void:
	pass
