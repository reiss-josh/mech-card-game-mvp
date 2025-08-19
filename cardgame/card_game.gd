extends Node
class_name CardGame

var basic_attack_data = load("res://cardgame/cards/uniquecards/basic_attack.tres")
var energy_card_data = load("res://cardgame/cards/uniquecards/ui_energy.tres")
var draw_card_data = load("res://cardgame/cards/uniquecards/ui_draw.tres")
#store our card locations
@onready var card_hand : CardLocation = get_node("CardHand")
@onready var draw_pile : CardLocation = get_node("DrawPile")
@onready var discard_pile : CardLocation = get_node("DiscardPile")
@onready var play_pile : CardLocation = get_node("PlayPile")
@onready var card_queue : CardLocation = get_node("CardQueue")
@onready var draw_queue : CardLocation = get_node("DrawQueue")
@onready var card_hud : CardHud = $CardHud
var _prepared_lockin : bool = false
var _discard_mode : bool = false
signal locked_in(queue_array) #signals to GameMaster that we're ready to play


func _ready() -> void:
	#set up our deck
	draw_pile.create_from_decklist("basic_deck")
	#fill up our hand to hand size
	draw_card_to_from(card_hand, draw_pile, PlayerVariables.max_player_hand_size)
	start_turn()
	_connect_child_signals()


func _process(_delta) -> void:
	if Input.is_action_just_pressed("DrawCard"):
		draw_card_to_from(card_hand, draw_pile)
	if Input.is_action_just_pressed("ReturnCard"):
		_undo_last_queue()
	if Input.is_action_just_pressed("CreateCard"):
		draw_pile.create_card(basic_attack_data)
	if Input.is_action_just_pressed("DiscardCard"):
		discard_card()


## Connects all the necessary signals from children
func _connect_child_signals():
	card_hand.card_selected.connect(_on_card_selected)
	card_hud.LockInButton.pressed.connect(_on_lockin_clicked)
	card_hud.EnergyButton.pressed.connect(_on_gain_energy_clicked)
	card_hud.DrawButton.pressed.connect(_on_draw_card_clicked)


## Draws a card to [destination] from [source] (defaults to draw_pile)
## Takes optional [quantity] parameter
func draw_card_to_from(destination : CardLocation, source : CardLocation = draw_pile, quantity : int = 1) -> void:
	for cards in quantity:
		var drawn_card = source.draw_card()
		if drawn_card is Card2D:
			destination.add_card(drawn_card)


## Discards a card from the card hand, and adds it to the discard pile
## Takes optional [hand_position] parameter
func discard_card(hand_position : int = -1) -> void:
	if(card_hand.card_array_size <= 0):
		return
	if(hand_position < 0):
		hand_position = card_hand.card_array_size-1
	var card = card_hand.draw_card(hand_position)
	card.last_hand_position = -1
	discard_pile.add_card(card)


## Discards specifically requested [card] from the card hand
func discard_specific_card(card : Card2D) -> void:
	if card_hand.card_array_size <= 0:
		return
	card_hand.draw_specific_card(card)
	card.last_hand_position = -1
	discard_pile.add_card(card)


## Makes hand visible, makes buttons visible, draws a card from the deck
func start_turn() -> void:
	_prepare_cancel_lockin(false)
	PlayerVariables.curr_player_clicks = PlayerVariables.max_player_clicks
	card_queue.show_location()
	draw_queue.show_location()
	draw_card_to_from(card_hand, draw_pile)


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
	#dump the draw queue
	draw_queue.dump_card_array()


## Handles [card] being clicked
func _on_card_selected(card : Card2D) -> void:
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


## Checks if [card] can be legally played; returns true/false
func _card_can_be_played(card : Card2D) -> bool:
	var card_energy_cost = card.data.card_energy_cost
	if((card_energy_cost <= PlayerVariables.curr_player_energy) and !card_queue.card_array_isfull):
		return true
	return false


## Plays [card] to the queue, and handles any interactions
func _play_card(card : Card2D) -> void:
	card_hand.draw_specific_card(card)
	if(card.data.card_type == "Draw"):
		draw_queue.add_card(card)
	elif(card.data.card_type == "Play"):
		play_pile.add_card(card)
	else:
		card_queue.add_card(card)
	manage_card_play_cancel(card, true)
	if(card_queue.card_array_isfull): #check if the queue still has room after playing the new card
		_prepare_cancel_lockin(true)


## Gains 1 energy when signalled by UI
func _on_gain_energy_clicked() -> void:
	if(card_queue.card_array_isfull):
		return
	_play_card(card_hand.create_card(energy_card_data))


## Draws a card into the hand when signalled by UI
func _on_draw_card_clicked() -> void:
	if(card_queue.card_array_isfull):
		return
	_play_card(card_hand.create_card(draw_card_data))


## Handls CardHud signalling that we've LOCKED IN
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
	if(last_queued_card is not Card2D):
		return
	manage_card_play_cancel(last_queued_card, false)
	if(last_queued_card.data.card_name == "Basic Energy"):
		last_queued_card.free()
	else:
		card_hand.add_card(last_queued_card)
	
	#if removing this card cancels our lockin,
	if(_prepared_lockin):
		_prepare_cancel_lockin(false)


## Performs / cancels pre-lockin procedures, depending on [is_preparing]
func _prepare_cancel_lockin(is_preparing : bool = true)-> void:
	#update flag
	_prepared_lockin = is_preparing
	#update HUD
	card_hud.LockInButton.visible = is_preparing
	card_hud.ActionButtons.visible = !is_preparing
	#hide locations
	if(is_preparing):
		card_hand.hide_location()
		draw_pile.hide_location()
		discard_pile.hide_location()
	else:
		card_hand.show_location()
		draw_pile.show_location()
		discard_pile.show_location()


## Handles playing / cancelling of [card]
## Takes [is_playing] - {true} if playing, {false} if cancelling
func manage_card_play_cancel(card : Card2D, is_playing: bool = true) -> void:
	var play_cancel_mult = int(is_playing)
	if(play_cancel_mult == 0): play_cancel_mult = -1
	
	_update_player_values(-card.data.card_energy_cost * play_cancel_mult, -play_cancel_mult)
	match(card.data.card_type):
		"Energy":
			_update_player_values(card.data.card_value * play_cancel_mult, 0)
		"Draw":
			if(is_playing): draw_card_to_from(card_hand, draw_pile, card.data.card_value * play_cancel_mult)
			else: discard_card()


## Updates player energy global by [energy_change] and click global by [click_change].
## Updates HUD to reflect changes.
func _update_player_values(energy_change : int, click_change : int) -> void:
	#update globals
	PlayerVariables.curr_player_energy += energy_change
	PlayerVariables.curr_player_clicks += click_change
	#update the hud display
	card_hud.energy_value = PlayerVariables.curr_player_energy #update the energy display
	card_hud.click_value = PlayerVariables.curr_player_clicks #update the click display
