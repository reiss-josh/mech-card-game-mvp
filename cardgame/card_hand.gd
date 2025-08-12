extends Node2D
## Manages cards held within a generic CardHand Node2D
## Can add, remove, and input-report for card_2D objects
## Any card_2D objects passed in must be preloaded with card_data

var card_array := [] ## array of cards in hand
var card_buffer = Vector2(500,40) ## distance cards should be apart from eachother in hand (in pixels)
var card_prefab := load("res://cardgame/cards/card_2D.tscn") ##Prefab for card_2D


# variables for card interaction management
var card_interaction_queued_event = null ## input event for highest-indexed card interacted with this frame
var card_interaction_queued_hand_position := -1 ## highest-position card interacted with this frame
var is_interactable := true ## whether hand should respond to input
signal card_selected(card) ## signal for card being played

func _ready():
	is_interactable = true
	var screen_size := get_viewport_rect().size ## stores screen size
	position.x = screen_size.x * 1/2
	position.y = screen_size.y * .99
	
func _process(_delta):
	if card_interaction_queued_event != null: #check and resolve card queue
		resolve_card_interaction_queue.call_deferred(card_array[card_interaction_queued_hand_position], card_interaction_queued_event)

## Connects all necessary signals from child card to this node
func connect_card_signals(card):
	card.get_node("CardCollisionArea").input_event.connect(_on_card_area_2d_input_event.bind(card))
	card.get_node("CardCollisionArea").mouse_entered.connect(_on_card_mouse_entered.bind(card))
	card.get_node("CardCollisionArea").mouse_exited.connect(_on_card_mouse_exited.bind(card))

## Disconnects all necessary signals from child card to this node
func disconnect_card_signals(card):
	card.get_node("CardCollisionArea").input_event.disconnect(_on_card_area_2d_input_event)
	card.get_node("CardCollisionArea").mouse_entered.disconnect(_on_card_mouse_entered)
	card.get_node("CardCollisionArea").mouse_exited.disconnect(_on_card_mouse_exited)

## Draws a new card into hand
#TODO: this function currently *creates* the card, but should be pulling it from some Deck object
func draw_card(data):
	var card = card_prefab.instantiate()
	card.data = data
	add_child(card)
	add_card(card)

## Places card in hand. If card has a last_hand_position, the card is returned to that position.
func add_card(card):
	card.reparent(self)
	card.scale = card.start_scale * 1
	if(card.last_hand_position < 0): #if card does not have a last_hand_position, set it to match the rightmost edge of the hand
		card.last_hand_position = card_array.size()
	card_array.insert(card.last_hand_position,card) #insert the card into card_array at last_hand_position
	connect_card_signals(card) #connect the card's signals
	rearrange_cards() #rearrange hand
	
## Removes card from hand. Updates card's last_hand_position to match current position.
func remove_card(card_array_position : int, card = card_array[card_array_position]):
	card.last_hand_position = card_array_position
	card.end_highlight() #ensure card is not selected
	card_array.remove_at(card_array_position) #remove the card from card_array
	disconnect_card_signals(card) #disconnect the card's signals
	rearrange_cards() #rearrange hand
	return card

## Removes card from hand. 
func play_card_from_hand(card):
	remove_card(card_array.find(card), card)
	card_selected.emit(card) #emit signal to parent, indicating card has been played

## Rearranges cards on the screen
func rearrange_cards():
	var curr_hand_size := card_array.size() # store current hand size
	var middle_card_index := ((curr_hand_size+1)/2.0) -1.0 # get index of middle card (or index between middle two cards)
	var dist_from_center := 0.0 # holder for later
	# crawl over the cards in the array.
	# if the cards
	for curr_card_index in curr_hand_size:
		var curr_card = card_array[curr_card_index] # save our current card
		dist_from_center = curr_card_index - middle_card_index # determine our index distance from the middle card
		curr_card.z_index = floor(dist_from_center)
		curr_card.move_to(Vector2(dist_from_center * (card_buffer.x/curr_hand_size), abs(dist_from_center)*(card_buffer.y / curr_hand_size)))
		curr_card.rotation = lerpf(0, TAU/18, dist_from_center/curr_hand_size)

## Enqueues input events from generic 2d_input_event signals
func _on_card_area_2d_input_event(_viewport, event, _shape_idx, card):
	if(is_interactable and card.need_move == false):
		attempt_card_interaction_enqueue(card, event)

## Enqueues custom event for mouse_entered signals
func _on_card_mouse_entered(card):
	if(is_interactable and card.need_move == false):
		attempt_card_interaction_enqueue(card, "mouse_entered")

## Enqueues custom event for mouse_exited signals
func _on_card_mouse_exited(card):
	if(is_interactable and card.need_move == false):
		attempt_card_interaction_enqueue(card, "mouse_exited")

## Attempts to enqueue event from card for interaction this frame
## Compares against currently enqueued events, if any exist, to ensure the highest card in hand is preferred
## (Also handles certain special cases)
func attempt_card_interaction_enqueue(card, event):
	var card_queue_pos = card_array.find(card)
	"""
	# If the card one above/below is already enqueued, and is highlighted, then don't enqueue current card.
	if (abs(card.last_hand_position - card_interaction_queued_hand_position) == 1) and (card_array[card_interaction_queued_hand_position].need_highlight):
		pass
	elif (abs(card.last_hand_position - card_interaction_queued_hand_position) == 1) and (card.need_highlight):
		var dist_to_old = 0 # distance from mouse cursor to origin of card
		var dist_to_new = 1 # distance from mouse cursor to origin of card
		if (dist_to_new > dist_to_old):
			card_interaction_queued_hand_position = card.last_hand_position
			card_interaction_queued_event = event
		else:
			card.end_highlight()
	"""
	# Enqueue if any of the following:
	# 	case 1: card is highest in the hand
	# 	case 2: card is tied for highest position, and event is a String (overrides clicks/mouse movements with custom events)
	if (
			(card_queue_pos > card_interaction_queued_hand_position) or (
			(card_queue_pos == card_interaction_queued_hand_position) and (event is String)) 
		):
		card_interaction_queued_hand_position = card_queue_pos
		card_interaction_queued_event = event
	# if card is currently highlighted, but didn't get enqueued this frame, end the highlight.
	elif card_queue_pos != card_interaction_queued_hand_position and card.need_highlight == true:
		card.end_highlight()

## Performs the input event associated with the card which is highest up in the hand
func resolve_card_interaction_queue(card, event):
	#handle mouse-click on card
	if event is InputEventMouseButton and event.pressed:
		is_interactable = false
		play_card_from_hand(card)
	elif event is String:
		if event == "mouse_entered":
			card.start_highlight()
		elif event == "mouse_exited":
			card.end_highlight()
	elif event is InputEventMouseMotion:
		card.start_highlight()
	#reset the card queue variables
	card_interaction_queued_hand_position = -1
	card_interaction_queued_event = null
