extends Node
#class_name DeckListManager

var decks_path := "res://cardgame/cards/decklists/"
var card_data_path := "res://cardgame/cards/uniquecards/"


## Takes a deck_filename string, and returns the array of data stored in that json
func load_deck_json(deck_filename : String) -> Array[CardData]:
	var card_array : Array[CardData]
	var deck_path = decks_path+deck_filename+".json"
	
	#try loading the deck
	#print("loading deck at " + deck_path + "...")
	if not FileAccess.file_exists(deck_path):
		return card_array

	#do the actual file access
	var file_access := FileAccess.open(deck_path, FileAccess.READ)
	var json_string := file_access.get_as_text()
	file_access.close()

	#parse the json
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return card_array
	
	# Get those cards!! parse that card data!!
	#TODO: could make this much better by caching loaded cards
	#(e.g. if we load basic_move, we store it. if we find another basic_move later, rather than loading the file again, we can just reference our stored data.
	var data:Dictionary = json.data
	for card_name in data.get("cards"):
		var curr_card_data_path : String = card_data_path+card_name+".tres"
		var curr_card_data : CardData = load(curr_card_data_path)
		card_array.append(curr_card_data)
	return card_array


## Takes an array of CardData and a DeckName, and saves it as a json
#TODO
func save_deck_json(_deck_filename : String, _deck_array : Array[CardData]) -> void:
	#convert the _deck_array to a dictionary of cards
	#var json_string := JSON.stringify(converted_deck_array)
	
	#var file_access := FileAccess.open(save_path, FileAccess.WRITE)
	#if not file_access:
	#	print("An error happened while saving data: ", FileAccess.get_open_error())
	#	return
	#file_access.store_line(json_data)
	#file_access.close()
	pass
