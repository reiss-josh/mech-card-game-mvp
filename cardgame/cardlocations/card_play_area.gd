extends CardLocation
class_name CardPlayArea

signal request_discard(card)
signal card_effect(type : String, value : int)


## Function for rearranging screen position on _ready
## {OVERLOAD}
# TODO
func _self_setup() -> void:
	var screen_size = get_viewport_rect().size
	self.position.y = screen_size.y * 1/2
	self.position.x = screen_size.x * 1/2
	_HIDE_OFFSET = Vector2(-screen_size.x, 0)
	_is_interactable_type = true


## Performs any start-of-turn effects in played cards
func handle_start_turn() -> void:
	for card in _card_array:
		card.handle_turn_start()


## Update last_hand_position, connect signals
## {OVERRIDE}
func _card_addition_unique(_insert_position : int, card: Card2D) -> void:
	card.need_discard.connect(_request_discard_handler.bind(card))
	card.card_effect.connect(_card_effect_handler)
	card.handle_play_card()


## Updates last_hand_position, disconnect signals
## {OVERRIDE}
func _card_removal_unique(_card_array_position : int, card : Card2D):
	card.handle_unplay_card()
	card.need_discard.disconnect(_request_discard_handler)
	card.card_effect.disconnect(_card_effect_handler)


## Performs the actual rearrangement of each [card] at [curr_card_index]
## {OVERRIDE}
var _CARD_BUFFER := Vector2(1.1 * Global.CARD_SIZE.x, 0) ## distance cards should be apart from eachother in hand (in pixels)
func _rearrange_helper(card : Card2D, curr_card_index : int) -> void:
	var middle_card_index := ((_card_array.size() + 1) / 2.0) - 1.0 # get index of middle card (or index between middle two cards)
	var dist_from_center := curr_card_index - middle_card_index
	card.z_index = -5 + floor(dist_from_center)
	card.move_and_scale(Vector2(dist_from_center * _CARD_BUFFER.x,0))
	card.rotation = 0


#TODO: not this
func _request_discard_handler(card : Card2D):
	request_discard.emit(card)


#TODO: not this
func _card_effect_handler(type : String, value : int):
	card_effect.emit(type, value)
