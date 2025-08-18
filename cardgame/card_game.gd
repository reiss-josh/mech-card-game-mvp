extends Node
class_name CardGame

var basic_attack_data = load("res://cardgame/cards/uniquecards/basic_attack.tres")
var energy_card_data = load("res://cardgame/cards/uniquecards/basic_energy.tres")
#store our card locations
@onready var card_hand : CardLocation = get_node("CardHand")
@onready var draw_pile : CardLocation = get_node("DrawPile")
@onready var discard_pile : CardLocation = get_node("DiscardPile")
@onready var card_queue : CardLocation = get_node("CardQueue")
@onready var card_hud : CardHud = $CardHud
var _prepared_lockin : bool = false
var _discard_mode : bool = false
signal locked_in(queue_array) #signals to GameMaster that we're ready to play


func _ready() -> void:
	#set up our deck
	draw_pile.create_from_decklist("basic_deck")
	#fill up our hand to hand size
	for i in PlayerVariables.max_player_hand_size:
		draw_card_from_to(card_hand, draw_pile)
	start_turn()
	
	_connect_child_signals()

func _connect_child_signals():
	card_hand.card_selected.connect(_card_selected)
	card_hud.LockInButton.pressed.connect(_on_lockin_clicked)
	card_hud.EnergyButton.pressed.connect(_on_gain_energy_clicked)


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
func discard_card(hand_position : int = -1) -> void:
	if(card_hand.card_array_size <= 0):
		return
	if(hand_position < 0):
		hand_position = card_hand.card_array_size-1
	var card = card_hand.draw_card(hand_position)
	card.last_hand_position = -1
	discard_pile.add_card(card)
	
	
## Discards specifically requested card
func discard_specific_card(card : Card2D) -> void:
	if card_hand.card_array_size <= 0:
		return
	discard_card(card_hand._card_array.find(card))


## Makes hand visible, makes buttons visible, draws a card from the deck
func start_turn() -> void:
	_prepare_cancel_lockin(false)
	card_queue.show_location()
	draw_card_from_to(card_hand, draw_pile)


## Hides the hand, hides the buttons
func end_turn() -> void:
	# check if we need to discard -- if so, stop ending the turn, and toggle discard mode
	if(card_hand.card_array_size > PlayerVariables.max_player_hand_size):
		card_hand.show_location()
		_discard_mode = true
		return
	
	# do the rest of the end-turn stuff
	# update HUD
	card_hud.LockInButton.visible = false
	card_hud.LockInButton.button_pressed = false


## Handles a card being clicked
func _card_selected(card) -> void:
	# check if we're in discard mode -- if so, try to discard, then see if we can end the turn.
	if(_discard_mode):
		discard_specific_card(card)
		if(card_hand.card_array_size <= PlayerVariables.max_player_hand_size): #check if we can end the turn yet
			_discard_mode = false
			card_hand.hide_location()
			end_turn()
		return
	# if we're not in discard mode, we continue the regular card playing procedure:
	if(_card_can_be_played(card)): # check if card can be played
		_play_card(card) # place the card in play area, pay relevant costs
	else:
		card_hand.fail_interaction(card)


## Checks if a card can be legally played; returns true/false
func _card_can_be_played(card) -> bool:
	var card_energy_cost = card.data.card_energy_cost
	if((card_energy_cost <= PlayerVariables.curr_player_energy) and !card_queue.card_array_isfull):
		return true
	return false


## Plays a card to the queue
func _play_card(card) -> void:
	card_hand.draw_specific_card(card) #pull the card out of the hand
	card_queue.add_card(card) #play the card to the queue
	manage_card_play_cancel(card, true)
	if(card_queue.card_array_isfull): #check if the queue still has room after playing the new card
		_prepare_cancel_lockin(true)


## TODO: Draws a card into the hand when signalled by UI
func _on_draw_card_clicked() -> void:
	pass
	#check if there's any room left in queue
	# if yes:
		# draw a card from the deck into the hand
		# block out the rightmost slot of queue with a "drew card"
		# if there's no more room in the queue, immediately lock in


## Gains 1 energy
func _on_gain_energy_clicked() -> void:
	if(card_queue.card_array_isfull):
		return
	card_queue.create_card(energy_card_data)
	_update_player_energy(1)
	if(card_queue.card_array_isfull): #check if the queue still has room after playing the new card
		_prepare_cancel_lockin(true)


#handle CardHud signalling that we've LOCKED IN
func _on_lockin_clicked() -> void:
	print("!!ACTION!!")
	locked_in.emit(card_queue._card_array)
	end_turn()


## Removes most-recently-queued card
## Makes UI available, if it was previously hidden
func _undo_last_queue()-> void:
	#early return if we're about to do an index OOB
	if(card_queue.card_array_size <= 0):
		return
	#gets the card out, and updates the HUD
	var last_queued_card = card_queue.draw_card()
	manage_card_play_cancel(last_queued_card, false)
	if(last_queued_card.data.card_name == "Basic Energy"):
		last_queued_card.free()
	else:
		card_hand.add_card(last_queued_card)
	
	#if removing this card cancels our lockin,
	if(_prepared_lockin):
		_prepare_cancel_lockin(false)


## Gets the LOCK IN button ready
func _prepare_cancel_lockin(is_preparing : bool = true)-> void:
	#update flag
	_prepared_lockin = is_preparing
	#update HUD
	card_hud.LockInButton.visible = is_preparing
	card_hud.EnergyButton.visible = !is_preparing
	#hide locations
	if(is_preparing):
		card_hand.hide_location()
		draw_pile.hide_location()
		discard_pile.hide_location()
	else:
		card_hand.show_location()
		draw_pile.show_location()
		discard_pile.show_location()


#handles energy updates for played cards
func manage_card_play_cancel(card : Card2D, is_playing: bool = true) -> void:
	var play_cancel_mult = int(is_playing)
	if(play_cancel_mult == 0): play_cancel_mult = -1
	
	_update_player_energy(-card.data.card_energy_cost * play_cancel_mult)
	if(card.data.card_type == "Energy"):
		_update_player_energy(card.data.card_value * play_cancel_mult)


## Updates player energy global.
## Updates the hud to reflect changes.
func _update_player_energy(energy_change : int) -> void:
	PlayerVariables.curr_player_energy += energy_change
	card_hud.energy_value = PlayerVariables.curr_player_energy #update the energy display
