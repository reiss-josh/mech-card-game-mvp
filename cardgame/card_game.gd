extends Node2D
class_name CardGame

var basic_move_data := load("res://cardgame/cards/uniquecards/basic_move.tres")
var basic_attack_data := load("res://cardgame/cards/uniquecards/basic_attack.tres")
var screen_size := Vector2.ZERO ## stores screen size
#store our card locations
@onready var card_hand : CardLocation = get_node("CardHand")
@onready var draw_pile : CardLocation = get_node("DrawPile")
@onready var discard_pile : CardLocation = get_node("DiscardPile")
@onready var card_queue : CardLocation = get_node("CardQueue")
signal ready_for_lockin(bool) #signals to GameMaster that we are/aren't ready to lock in
signal locked_in(queue_array) #signals to GameMaster that we're ready to play
signal update_player_energy()


func _ready() -> void:
	card_hand.card_selected.connect(_card_selected)
	discard_pile.reposition_deck(2)
	screen_size = get_viewport_rect().size
	
	draw_pile.create_card(basic_attack_data)
	draw_card_from_to(card_hand, draw_pile)
	discard_card(discard_pile)


func _process(_delta) -> void:
	if Input.is_action_just_pressed("DrawCard"):
		draw_card_from_to(card_hand)
	if Input.is_action_just_pressed("ReturnCard"):
		_undo_last_queue()
	if Input.is_action_just_pressed("CreateCard"):
		draw_pile.create_card(basic_attack_data)
	if Input.is_action_just_pressed("DiscardCard"):
		discard_card()


## Takes a destination and adds a card to it from the draw pile (can manually specify a deck instead)
func draw_card_from_to(destination, deck = draw_pile) -> void:
	var drawn_card = deck.draw_card()
	if drawn_card is Card2D:
		destination.add_card(drawn_card)


## Discards a card from the card hand, and adds it to the discard pile (can manually specify a deck instead)
func discard_card(destination = discard_pile, hand_position : int = -1) -> void:
	if(card_hand.card_array_size < 1):
		return
	if(hand_position < 0):
		hand_position = card_hand.card_array_size-1
	var card = card_hand.draw_card(hand_position)
	card.last_hand_position = -1
	destination.add_card(card)


## TODO: Does all the setup for starting a turn
# makes hand visible, makes buttons visible, draws a card from the deck
func start_turn() -> void:
	pass


## TODO: Does all the cleanup for ending a turn
# hides the hand, hides the buttons, discards down to max_player_hand_size
func end_turn() -> void:
	pass


## Handles a card being clicked
func _card_selected(card) -> void:
	# check if card can be played
	if(_card_can_be_played(card)):
		_play_card(card) # place the card in play area, pay relevant costs
	else:
		card_hand.fail_interaction(card)


## Checks if a card can be legally played; returns true/false
func _card_can_be_played(card) -> bool:
	var card_energy_cost = int(card.card_data["EnergyCost"].text)
	if((card_energy_cost <= PlayerVariables.curr_player_energy) and !card_queue.card_array_isfull):
		return true
	return false


## TODO: Plays a card to the queue
func _play_card(card) -> void:
	card_hand.draw_specific_card(card) #pull the card out of the hand
	card_queue.add_card(card) #play the card to the queue
	update_player_energy.emit(-int(card.card_data["EnergyCost"].text)) #update energy global
	if(!card_queue.card_array_isfull): #check if the queue still has room after playing the new card
		return
	else: #if not, hide the hand, and display the LOCK IN button
		_prepare_lockin()


## TODO: Draws a card into the hand when signalled by UI
func _on_draw_card_clicked() -> void:
	pass
	#check if there's any room left in queue
	# if yes:
		# draw a card from the deck into the hand
		# block out the rightmost slot of queue with a "drew card"
		# if there's no more room in the queue, immediately lock in


## TODO: Gains an energy when signalled by UI
func _on_gain_energy_clicked() -> void:
	pass
	#check if there's any room left in queue
	# if yes:
		# gain 1 energy
		# add an energy gain card into the queue at rightmost slot
		# if there's no more room in the queue, show the LOCK IN button


## TODO: Hides the hand, displays the LOCK IN button
func _prepare_lockin()-> void:
	ready_for_lockin.emit(true)
	card_hand.hide_hand()
	#display lockin button


## Removes most-recently-queued card
func _undo_last_queue()-> void:
	if(card_queue.card_array_size <= 0):
		return
	var last_queued_card = card_queue.draw_card()
	update_player_energy.emit(int(last_queued_card.card_data["EnergyCost"].text))
	card_hand.add_card(last_queued_card)
	card_hand.is_interactable = true
	ready_for_lockin.emit(false)
