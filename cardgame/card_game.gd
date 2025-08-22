extends Node
class_name CardGame

#card data
var energy_card_data = load("res://cardgame/cards/uniquecards/ui/ui_energy.tres")
var draw_card_data = load("res://cardgame/cards/uniquecards/ui/ui_draw.tres")
var move_card_data = load("res://cardgame/cards/uniquecards/ui/ui_move.tres")
var deck_list_name : String = "basic_deck"
var _clicks_this_turn = []
#store our card locations
@onready var card_hand : CardLocation = find_child("CardHand")
@onready var draw_pile : CardLocation = find_child("DrawPile")
@onready var discard_pile : CardLocation = find_child("DiscardPile")
@onready var play_pile : CardLocation = find_child("PlayPile")
@onready var card_queue : CardLocation = find_child("CardQueue")
@onready var draw_queue : CardLocation = find_child("DrawQueue")
@onready var card_hud : CardHud = find_child("CardHud")
#for locking in
var _prepared_lockin : bool = false
var _discard_mode : bool = false
signal locked_in(queue_array) #signals to GameMaster that we're ready to play


## Fills up the draw deck, connects child signals, draws starting hand, then calls start_turn()
func _ready() -> void:
	#set up our deck
	draw_pile.create_from_decklist(deck_list_name)
	#fill up our hand to hand size
	_connect_child_signals()
	draw_card_to_from(card_hand, draw_pile, Global.PlayerVariables["max_hand_size"])
	start_turn()


## Handles debug inputs
func _process(_delta) -> void:
	if Input.is_action_just_pressed("DrawCard"):
		draw_card_to_from(card_hand, draw_pile)
	if Input.is_action_just_pressed("ReturnCard"):
		_undo_last_queue()
	if Input.is_action_just_pressed("CreateCard"):
		draw_pile.create_card(energy_card_data)
	if Input.is_action_just_pressed("DiscardCard"):
		discard_card()
	if Input.is_action_just_pressed("StartTurn"):
		card_queue.dump_card_array()
		start_turn()
	if Input.is_action_just_pressed("TempDebug"):
		card_hand._rearrange_cards()


## Connects all the necessary signals from children
func _connect_child_signals():
	card_hand.card_selected.connect(_on_card_selected)
	card_hud.LockInButton.pressed.connect(_on_lockin_clicked)
	card_hud.EnergyButton.pressed.connect(_on_gain_energy_clicked)
	card_hud.DrawButton.pressed.connect(_on_draw_card_clicked)
	card_hud.MoveButton.pressed.connect(_on_move_card_clicked)
	play_pile.request_discard.connect(discard_specific_card.bind(play_pile))
	play_pile.card_effect.connect(handle_card_effect)


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


## Discards specifically requested [card] from the card [location] (defaults to hand)
func discard_specific_card(card : Card2D, location : CardLocation = card_hand) -> void:
	if card_hand.card_array_size <= 0:
		return
	location.draw_specific_card(card)
	card.last_hand_position = -1
	discard_pile.add_card(card)


## Makes hand visible, makes buttons visible, draws a card from the deck
func start_turn() -> void:
	Global.PlayerVariables["curr_clicks"] = 0
	_clicks_this_turn = []
	_prepare_cancel_lockin(false)
	_update_player_values("Click",Global.PlayerVariables["max_clicks"])
	card_queue.show_location()
	draw_queue.show_location()
	draw_card_to_from(card_hand, draw_pile)
	play_pile.handle_start_turn()


## Hides the hand, hides the buttons
func end_turn() -> void:
	# check if we need to discard -- if so, stop ending the turn, and toggle discard mode
	if(card_hand.card_array_size > Global.PlayerVariables["max_hand_size"]):
		card_hand.show_location()
		_discard_mode = true
		return
	# Otherwise, do the rest of the end-turn stuff
	# update HUD
	card_hud.LockInButton.visible = false
	card_hud.LockInButton.button_pressed = false
	#dump the draw queue -- TODO: make this animate
	draw_queue.dump_card_array()


## Handles [card] being clicked
func _on_card_selected(card : Card2D) -> void:
	# check if we're in discard mode -- if so, try to discard, then see if we can end the turn.
	if(_discard_mode):
		discard_specific_card(card)
		await card.arrived
		if(card_hand.card_array_size <= Global.PlayerVariables["max_hand_size"]): #check if we can end the turn yet
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
	if((card_energy_cost <= Global.PlayerVariables["curr_energy"]) and !card_queue.card_array_isfull):
		return true
	return false


## Plays [card] to the queue, and handles any interactions
func _play_card(card : Card2D) -> void:
	card_hand.draw_specific_card(card)
	if(card.data.card_is_persistent):
		play_pile.add_card(card)
	else:
		card_queue.add_card(card)
	manage_card_play_cancel(card, true)
	await card.arrived
	_clicks_this_turn.append(card)
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


## Plays a basic move card when signalled by UI
func _on_move_card_clicked() -> void:
	if(card_queue.card_array_isfull):
		return
	_play_card(card_hand.create_card(move_card_data))


## Handls CardHud signalling that we've LOCKED IN
func _on_lockin_clicked() -> void:
	print("!!ACTION!!")
	locked_in.emit(card_queue._card_array)
	end_turn()


## Removes most-recently-queued card
## Makes UI available, if it was previously hidden
func _undo_last_queue()-> void:
	#early return if there isn't a _last_played_card, or if the _last_played_card was permanent
	if(_clicks_this_turn.is_empty()): return
	
	#check if the card is in the queue or not, then get it
	var last_click = _clicks_this_turn.back()
	if (last_click is Card2D):
		var card
		if(last_click.data.card_cannot_undo):
			return
		elif(last_click.data.card_is_persistent):
			card = play_pile.draw_card()
		else:
			card = card_queue.draw_card()
		if(card.data.card_name.contains("UI ")):
			manage_card_play_cancel(card, false)
			card.free()
		else:
			#handle the card being undone
			card_hand.add_card(card)
			await card.arrived
			manage_card_play_cancel(card, false)
	else:
		#TODO: how do we handle undoing card clicks?
		pass
	_clicks_this_turn.pop_back()
	
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
		play_pile.hide_location()
	else:
		card_hand.show_location()
		draw_pile.show_location()
		discard_pile.show_location()
		play_pile.show_location()


## Handles playing / cancelling of [card]
## Takes [is_playing] - {true} if playing, {false} if cancelling
func manage_card_play_cancel(card : Card2D, is_playing: bool = true) -> void:
	var play_cancel_mult = int(is_playing)
	if(play_cancel_mult == 0): play_cancel_mult = -1
	#pay the click + energy cost
	_update_player_values("Energy", -card.data.card_energy_cost * play_cancel_mult)
	_update_player_values("Click", -play_cancel_mult)
	if(card.data.card_type == "Event"):
		match(card.data.card_subtype):
			"Energy":
				_update_player_values("Energy", card.data.card_value * play_cancel_mult)
			"Draw":
				if(is_playing): draw_card_to_from(card_hand, draw_pile, card.data.card_value * play_cancel_mult)
				else: discard_card()
			"Reload":
				_update_player_values("Ammo", card.data.card_value * play_cancel_mult)
			"Health":
				_update_player_values("Health", card.data.card_value * play_cancel_mult)


## Updates player energy global by [energy_change] and click global by [click_change].
## Updates HUD to reflect changes.
func _update_player_values(change_type : String, change_value : int) -> void:
	if(change_type == "Click"): change_type = "Clicks"
	var var_string = "curr_"+ change_type.to_lower()
	#print(var_string, "\tchange by:", change_value, "\tcurr: ", Global.PlayerVariables[var_string])
	#update globals
	Global.PlayerVariables[var_string] += change_value
	#update the hud display
	card_hud.update_hud()
	#card_hud.ammo_value = Global.PlayerVariablescurr_ammo
	if(Global.PlayerVariables["curr_clicks"] <= 0): #check if the queue still has room after playing the new card
		_prepare_cancel_lockin(true)


func handle_card_effect(type : String, value : int):
	_update_player_values(type, value)
