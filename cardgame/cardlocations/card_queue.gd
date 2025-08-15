extends CardLocation
class_name CardQueue

const CARD_QUEUE_SCALE = 0.5

## Function for rearranging screen position on _ready
#TODO
func _self_positioning() -> void:
	var screen_size = get_viewport_rect().size
	self.position.y = Global.CARD_SIZE.y/2 * CARD_QUEUE_SCALE
	self.position.x = screen_size.x * 1/2
	pass


## Function for determining whether location can fit more cards
func _card_array_isfull_helper() -> bool:
	if(self.card_array_size >= PlayerVariables.max_player_clicks):
		return true
	else:
		return false


## Performs the actual rearrangement
const _CARD_BUFFER := Vector2(10 + Global.CARD_SIZE.x * CARD_QUEUE_SCALE, 0) ## distance cards should be apart from eachother in hand (in pixels)
func _rearrange_helper(card : Card2D, curr_card_index : int) -> void:
	var middle_card_index := ((PlayerVariables.max_player_clicks - 1) / 2.0) # get index of middle card (or index between middle two cards)
	var dist_from_center := curr_card_index - middle_card_index
	card.z_index = 5
	card.move_to(Vector2(dist_from_center * _CARD_BUFFER.x, 0), CARD_QUEUE_SCALE)
	card.rotation = 0

## Special function to be overrloaded by special methods for children on card removal
#TODO
func _card_removal_unique(card_array_position: int, ret_card : Card2D):
	pass
