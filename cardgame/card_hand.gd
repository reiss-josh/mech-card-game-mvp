extends Node2D

var screen_size := Vector2.ZERO
var card_array := []
var card_buffer = 100
var card_interaction_queue := []
var hand_is_interactable := true
signal card_selected(card)

func _ready():
	hand_is_interactable = true
	screen_size = get_viewport_rect().size
	position.x = screen_size.x/2
	position.y = screen_size.y * 3/4
	
func _process(_delta):
	if !card_interaction_queue.is_empty():
		resolve_card_interaction_queue.call_deferred()

func connect_card_signals(card):
	card.get_node("CardCollisionArea").input_event.connect(_on_card_area_2d_input_event.bind(card))
	card.get_node("CardCollisionArea").mouse_entered.connect(_on_card_mouse_entered.bind(card))
	card.get_node("CardCollisionArea").mouse_exited.connect(_on_card_mouse_exited.bind(card))
	
func disconnect_card_signals(card):
	card.get_node("CardCollisionArea").input_event.disconnect(_on_card_area_2d_input_event)
	card.get_node("CardCollisionArea").mouse_entered.disconnect(_on_card_mouse_entered)
	card.get_node("CardCollisionArea").mouse_exited.disconnect(_on_card_mouse_exited)

#draws a new card into hand
func draw_card(data):
	var card = load("res://cardgame/cards/card_2D.tscn").instantiate()
	card.data = data
	add_child(card)
	card_array.append(card)
	card.last_hand_position = card_array.size()+1
	connect_card_signals(card)
	rearrange_cards()

#place card in hand at index
func place_card_in_hand(card):
	#add_child(card) #TODO: should this be here?
	if(card.last_hand_position == null):
		card.last_hand_posiion = card_array.size()+1
	card_array.insert(card.last_hand_position,card)
	connect_card_signals(card)
	rearrange_cards()

#remove card from hand at index
func play_card_from_hand(card):
	card.end_highlight()
	card.last_hand_position = card_array.find(card)
	card_array.remove_at(card.last_hand_position)
	rearrange_cards()
	disconnect_card_signals(card)
	card_selected.emit(card)

#rearranges cards on the screen
func rearrange_cards():
	var curr_hand_size := card_array.size() #current hand size
	var middle_card_index := ((curr_hand_size+1)/2.0) -1.0 #index of middle card (or index between middle two cards)
	var dist_from_center := 0.0 #holder for later
	#print("middle card index is ", middle_card_index, " with hand size ", curr_hand_size)
	#crawl over the cards in the array
	for curr_card_index in curr_hand_size:
		var curr_card = card_array[curr_card_index] #save our current card
		dist_from_center = curr_card_index - middle_card_index #determine our index distance from the middle card
		curr_card.z_index = floor(dist_from_center)
		#curr_card.position.x = (dist_from_center * card_buffer) #offset card position onscreen
		#curr_card.targetLayer = floor(dist_from_center)
		curr_card.move_to(Vector2(dist_from_center * card_buffer,0))

#gets input events from clicked cards and queues them
func _on_card_area_2d_input_event(_viewport, event, _shape_idx, card):
	if(hand_is_interactable):
		card_interaction_queue.append({"Card": card, "Event": event}) #queue a card click
		
func _on_card_mouse_entered(card):
	if(hand_is_interactable):
		card_interaction_queue.append({"Card": card, "Event": "mouse_entered"}) #queue a card click
		
func _on_card_mouse_exited(card):
	if(hand_is_interactable):
		card_interaction_queue.append({"Card": card, "Event": "mouse_exited"}) #queue a card click
	
#determines which clicked card is highest up in stack
func resolve_card_interaction_queue():
	#find the highest-indexed card
	var running_highest_card_index = -1
	var running_highest_card = null
	for queue_index in card_interaction_queue.size():
		var curr_item = card_interaction_queue[queue_index]
		if curr_item["Card"].last_hand_position > running_highest_card_index:
			running_highest_card = curr_item
			running_highest_card_index = curr_item["Card"].last_hand_position
		elif curr_item["Card"].last_hand_position == running_highest_card_index and curr_item["Event"] is String:
			running_highest_card = curr_item
		elif curr_item["Card"].need_highlight == true:
			curr_item["Card"].end_highlight()
			
	card_interaction_queue.clear()
	#print(running_highest_card["Card"].debug_name,running_highest_card["CardIndex"])
	
	#handle interaction
	var card = running_highest_card["Card"]
	var event = running_highest_card["Event"]
	#handle mouse-click on card
	if event is InputEventMouseButton and event.pressed:
		hand_is_interactable = false
		play_card_from_hand(card)
		#print("clicked ", card.debug_name)
	elif event is String:
		if event == "mouse_entered":
			card.start_highlight()
		elif event == "mouse_exited":
			card.end_highlight()
	elif event is InputEventMouseMotion:
		card.start_highlight()
