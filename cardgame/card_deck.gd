extends Node2D

var card_array := [] ## array of cards in hand
var card_buffer = 10 ## distance cards should be apart from eachother in hand (in pixels)

var is_interactable := true ## whether deck should respond to input
var card_prefab := load("res://cardgame/cards/card_2D.tscn") ##Prefab for card_2D
var card_size := Vector2(0.3*750, 0.3*1050)

func _ready():
	is_interactable = true
	var screen_size := get_viewport_rect().size ## stores screen size
	position.x = screen_size.x - card_size.x/2
	position.y = screen_size.y - card_size.y/2
	print(card_size)

#draws cards from the top and returns it
func draw_card() -> Card2D:
	if card_array.is_empty():
		return
	else:
		var ret_card = card_array.pop_back()
		rearrange_cards()
		return ret_card

## Creates new card from given data, and places at top of the deck
func create_card(data):
	var card = card_prefab.instantiate()
	card.data = data
	add_child(card)
	card_array.append(card)
	rearrange_cards()

## Adds card to top of deck (or sent position)
func add_card(card, insert_position: int = -1):
	card.reparent(self)
	if(insert_position >= 0):
		card_array.insert(insert_position,card) #insert the card into card_array at position
	else:
		card_array.append(card)
	rearrange_cards()
		
## Rearranges cards on the screen
func rearrange_cards():
	var curr_hand_size := card_array.size() # store current hand size
	# crawl over the cards in the array.
	for curr_card_index in card_array.size():
		var curr_card = card_array[curr_card_index] # save our current card
		var dist_from_top = curr_hand_size-1 - curr_card_index # determine our index distance from the middle card
		curr_card.z_index = curr_card_index
		curr_card.move_to(Vector2(0, dist_from_top * card_buffer))
		curr_card.rotation = 0
