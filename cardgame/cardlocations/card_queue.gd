extends CardLocation
class_name CardQueue

## Used to determine whether cards are inserted L to R or R to L
@export var left_to_right : int = 1


## Function for rearranging screen position on _ready
func _self_setup() -> void:
	var screen_size = get_viewport_rect().size
	self.position.y = Global.CARD_SIZE.y/2 * Global.CARD_QUEUE_SCALE
	self.position.x = screen_size.x * 1/2
	_HIDE_OFFSET = Vector2(0, -Global.CARD_SIZE.y * Global.CARD_QUEUE_SCALE * 1.5)
	_is_interactable_type = true


## Function for determining whether location can fit more cards
func _card_array_isfull_helper() -> bool:
	if(PlayerVariables.curr_player_clicks <= 0):
		return true
	else:
		return false


## Performs the actual rearrangement of each [card] at [curr_card_index]
## {OVERRIDE}
var _CARD_BUFFER := Vector2(Global.CARD_QUEUE_ADDITIONAL_BUFFER.x + Global.CARD_SIZE.x * Global.CARD_QUEUE_SCALE, 0) ## distance cards should be apart from eachother in hand (in pixels)
func _rearrange_helper(card : CardUI, curr_card_index : int) -> void:
	var middle_card_index := ((PlayerVariables.max_player_clicks - 1) / 2.0) # get index of middle card (or index between middle two cards)
	var dist_from_center := curr_card_index - middle_card_index
	card.z_index = -5 + floor(dist_from_center) + left_to_right
	card.move_and_scale(Vector2(left_to_right * dist_from_center * _CARD_BUFFER.x, 0), Global.CARD_QUEUE_SCALE)
	card.rotation = 0


## Update last_hand_position, connect signals
## {OVERRIDE}
const QUEUE_HIGHLIGHT_FACTOR = 1.5
const QUEUE_HIGHLIGHT_Y_OFFSET = (Global.CARD_SIZE.y * Global.CARD_QUEUE_SCALE * QUEUE_HIGHLIGHT_FACTOR/2) - (Global.CARD_SIZE.y * Global.CARD_QUEUE_SCALE/2)
func _card_addition_unique(_insert_position : int, card: CardUI) -> void:
	card.gui_input.connect(_on_card_input_event.bind(card))
	card.mouse_entered.connect(_on_card_input_event.bind("mouse_entered", card))
	card.mouse_exited.connect(_on_card_input_event.bind("mouse_exited", card))
	card.update_highlight_transform(QUEUE_HIGHLIGHT_FACTOR, QUEUE_HIGHLIGHT_Y_OFFSET)


## Disconnect signals
## {OVERRIDE}
func _card_removal_unique(_card_array_position : int, card : CardUI):
	card.gui_input.disconnect(_on_card_input_event)
	card.mouse_entered.disconnect(_on_card_input_event)
	card.mouse_exited.disconnect(_on_card_input_event)


## Performs the input event associated with the [card] which is highest up in the location
## {OVERRIDE}
# card_selected signal gets emitted from here
func _resolve_card_interaction_queue(card : CardUI, event) -> void:
	#handle mouse entry/exit
	if event is String:
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
