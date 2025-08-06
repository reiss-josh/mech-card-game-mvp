extends Node3D


class_name Card

@export var data:CardData:
	set(value):
		var card_Face = $"Front"
		var card_template = $"Front/SubViewport/CardTemplate"
		
		data = value
		
		card_template.get_node("Name").text = data.cardName
		card_template.get_node("Cost").text = data.cardCost
		card_template.get_node("CardBody").text = data.cardBody
		card_template.get_node("CardType").text = data.cardType
