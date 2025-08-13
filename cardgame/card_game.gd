extends Node2D
class_name CardGame

var basic_move_data := load("res://cardgame/cards/uniquecards/basic_move.tres")
var basic_attack_data := load("res://cardgame/cards/uniquecards/basic_attack.tres")
var card_held : Card2D
var card_held_index := 0
var screen_size := Vector2.ZERO ## stores screen size

func _ready() -> void:
	$CardHand.card_selected.connect(_card_selected)
	$CardDeck.create_card(basic_attack_data)
	draw_card_from_to($CardHand)
	screen_size = get_viewport_rect().size

func _process(_delta) -> void:
	if Input.is_action_just_pressed("DrawCard"):
		draw_card_from_to($CardHand)
	if Input.is_action_just_pressed("ReturnCard"):
		if(card_held != null):
			return_card_to_hand(card_held)
			card_held = null
	if Input.is_action_just_pressed("CreateCard"):
		$CardDeck.create_card(basic_move_data)
	if Input.is_action_just_pressed("DiscardCard"):
		discard_card()

func draw_card_from_to(destination, deck = $CardDeck) -> void:
	var drawn_card = deck.draw_card()
	if drawn_card is Card2D:
		destination.add_card(drawn_card)

func discard_card() -> void:
	if($CardHand.card_array.size() < 1):
		return
	var card = $CardHand.remove_card($CardHand.card_array.size()-1)
	card.last_hand_position = -1
	$CardDeck.add_card(card)

## Move card into selection area
func _card_selected(card) -> void:
	# TODO: check if card can be played
	
	# TODO: place the card in play area, pay relevant costs
	
	$CardHand.remove_card(card.last_hand_position, card)
	card.reparent(self)
	card.move_to(Vector2(screen_size.x * 1/2, screen_size.y * 1/4))
	card.rotation = 0
	card.z_index = 5
	card_held = card
	card_held_index = card.last_hand_position

## Return card to hand
func return_card_to_hand(card) -> void:
	$CardHand.add_card(card)
	$CardHand.is_interactable = true
