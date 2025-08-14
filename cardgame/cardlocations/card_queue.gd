extends CardLocation
class_name CardQueue


## Function for rearranging screen position on _ready
func _self_positioning() -> void:
	pass


## Function for determining whether location can fit more cards
func _card_array_isfull_helper() -> bool:
	if(self.card_array_size >= PlayerVariables.max_player_clicks):
		return true
	else:
		return false


## Performs the actual rearrangement
const _CARD_BUFFER := Vector2(500,40) ## distance cards should be apart from eachother in hand (in pixels)
func _rearrange_helper(card : Card2D, curr_card_index : int) -> void:
	var screen_size = get_viewport_rect().size
	card.move_to(Vector2(screen_size.x * 1/2, screen_size.y * 1/4))
	card.rotation = 0
	card.z_index = 5


## Special function to be overrloaded by special methods for children on card removal
func _card_removal_unique(card_array_position: int, ret_card : Card2D):
	pass
