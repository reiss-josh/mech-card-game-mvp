extends CardLocation
class_name CardDeckPhysical

## Function for rearranging screen position on _ready
func _self_positioning(card_lengths : int = 1) -> void:
	var screen_size := get_viewport_rect().size ## stores screen size
	position.x = screen_size.x - Global.CARD_SIZE.x/2
	position.y = screen_size.y - (Global.CARD_SIZE.y / 2 + (Global.CARD_SIZE.y * (card_lengths - 1)))


## For performing _self_positioning() at runtime
func reposition_deck(card_lengths : int = 1) -> void:
	_self_positioning(card_lengths)


## Performs the actual rearrangement
const _CARD_BUFFER = Vector2(10,0) ## distance cards should be apart from eachother in deck (in pixels)
func _rearrange_helper(card : Card2D, curr_card_index : int) -> void:
	var dist_from_top := card_array_size-1 - curr_card_index # determine our index distance from the middle card
	card.z_index = curr_card_index
	card.move_to(Vector2(0, dist_from_top * _CARD_BUFFER.x))
	card.rotation = 0
