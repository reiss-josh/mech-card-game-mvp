extends Node2D

var basic_move_data := load("res://cardgame/cards/uniquecards/basic_move.tres")
var basic_attack_data := load("res://cardgame/cards/uniquecards/basic_attack.tres")
var card_held = null
var card_held_index = 0
@onready var card_hand := $CardHand
@onready var card_deck := $CardDeck
var screen_size := Vector2.ZERO ## stores screen size

func _ready():
	$CardHand.card_selected.connect(_card_selected)
	#card_deck.create_card(basic_move_data)
	#card_deck.create_card(basic_attack_data)
	card_deck.create_card(basic_attack_data)
	draw_card_from_to(card_hand)
	#draw_card_from_to(card_hand)
	screen_size = get_viewport_rect().size

func _process(_delta):
	if Input.is_action_just_pressed("DrawCard"):
		draw_card_from_to(card_hand)
	if Input.is_action_just_pressed("ReturnCard"):
		if(card_held != null):
			return_card_to_hand(card_held)
			card_held = null
	if Input.is_action_just_pressed("CreateCard"):
		card_deck.create_card(basic_move_data)
	if Input.is_action_just_pressed("DiscardCard"):
		discard_card()

func draw_card_from_to(destination, deck = self.card_deck):
	var drawn_card = deck.draw_card()
	if drawn_card is Card2D:
		destination.add_card(drawn_card)
		
func discard_card():
	var card = card_hand.remove_card(card_hand.card_array.size()-1)
	card_deck.add_card(card)

## Move card into selection area
func _card_selected(card):
	card.reparent(self)
	card.move_to(Vector2(screen_size.x * 1/2, screen_size.y * 1/4))
	card.rotation = 0
	card.z_index = 5
	card_held = card
	card_held_index = card.last_hand_position

## Return card to hand
func return_card_to_hand(card):
	$CardHand.add_card(card)
	$CardHand.is_interactable = true
