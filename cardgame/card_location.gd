extends Node2D
class_name CardLocation
## Manages cards held within a card_array
## Can create, add, remove, and rearrange cards
## Any card_2D objects passed in must be preloaded with card_data

var card_array := [] ## array of cards in hand
var _card_prefab := load("res://cardgame/cards/card_2D.tscn") ##Prefab for card_2D
const CARD_SIZE := Vector2(0.3*750, 0.3*1050)
var is_interactable := true ## whether hand should respond to input

func _ready() -> void:
	is_interactable = true
	_self_positioning()


## Function for rearranging screen position on _ready
func _self_positioning() -> void:
	pass


## Creates new card from given data, and places at top of the deck
func create_card(data) -> void:
	var card : Card2D = _card_prefab.instantiate()
	card.data = data
	add_child(card)
	add_card(card)


## Adds card to top of deck (or specified position)
func add_card(card, insert_position: int = -1) -> void:
	card.reparent(self)
	card.scale = card.start_scale * 1
	if insert_position > card_array.size() or insert_position < 0:
		card_array.append(card)
	else:
		card_array.insert(insert_position,card) #insert the card into card_array at position
	_rearrange_cards()


## Draws a card from the top of the deck and returns it
func draw_card() -> Card2D:
	if card_array.is_empty():
		return
	var ret_card = card_array.pop_back()
	_rearrange_cards()
	return ret_card


## Removes card from hand at passed position. Updates card's last_hand_position to match current hand position
func draw_card_at(card_array_position : int) -> Card2D:
	if card_array_position < 0 or card_array_position > card_array.size():
		return
	var ret_card = card_array[card_array_position]
	_card_removal_unique(card_array_position, ret_card) #for hand management ... is this clumsy code?
	ret_card.end_highlight()
	card_array.remove_at(card_array_position)
	_rearrange_cards()
	return ret_card


## Special function to be overrloaded by special methods for children on card removal
func _card_removal_unique(card_array_position: int, ret_card : Card2D):
	pass


## Rearranges cards on the screen
func _rearrange_cards() -> void:
	for curr_card_index in card_array.size():
		_rearrange_helper(card_array[curr_card_index], curr_card_index)
	#TODO: emit a rearrangement sound (maybe should be in _rearrange_helper, actually??)


## Performs the actual rearrangement
func _rearrange_helper(_card : Card2D, _curr_card_index : int) -> void:
	pass
