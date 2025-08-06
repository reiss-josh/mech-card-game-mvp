extends Node2D

var basic_move_data := load("res://cardgame/cards/uniquecards/basic_move.tres")
var card_held = null
var card_held_index = 0

func _ready():
	$CardHand.draw_card(basic_move_data)
	$CardHand.draw_card(load("res://cardgame/cards/uniquecards/basic_attack.tres"))
	$CardHand.card_selected.connect(_card_selected)

func _process(_delta):
	if Input.is_action_just_pressed("spacebar"):
		$CardHand.draw_card(basic_move_data)
	if Input.is_action_just_pressed("enterkey"):
		if(card_held != null):
			return_card_to_hand(card_held, card_held_index)
			card_held = null

#move card into selection area
func _card_selected(card, card_index):
	card.reparent(self)
	card.position = Vector2.ZERO
	card_held = card
	card_held_index = card_index
	
func return_card_to_hand(card, card_index):
	card.reparent($CardHand)
	card.position = Vector2.ZERO
	$CardHand.place_card_in_hand(card, card_index)
	$CardHand.hand_is_interactable = true
