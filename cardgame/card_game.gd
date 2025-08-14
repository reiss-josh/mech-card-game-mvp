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
signal locked_in(queue_array) #signals to GameMaster that we're ready to play


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
		if(card_queue.card_array_size > 0):
			return_card_to_hand(card_queue.draw_card())
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
	_update_player_energy(-int(card.card_data["EnergyCost"].text)) #update energy global
	if(!card_queue.card_array_isfull): #check if the queue still has room after playing the new card
		return
	else: #if not, hide the hand, and display the LOCK IN button
		pass


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
	pass


## Return card to hand
func return_card_to_hand(card) -> void:
	_update_player_energy(int(card.card_data["EnergyCost"].text))
	card_hand.add_card(card)
	card_hand.is_interactable = true
	
	
func _update_player_energy(energy_change : int) -> void:
	PlayerVariables.curr_player_energy += energy_change
	$CardHud.energy_value = PlayerVariables.curr_player_energy #update the energy display
