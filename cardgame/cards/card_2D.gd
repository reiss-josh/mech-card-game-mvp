extends Node2D
class_name Card2D

# variables for carddata structure
var _card_hud_elts_dict := {}
var debug_name := ""
#const CARD_SIZE := Vector2(0.3*750, 0.3*1050)
# Card's last hand position, if applicable
var last_hand_position : int = -1
# variables for highlighting
const _HIGHLIGHT_Z_INDEX := 50
var need_highlight = false
@onready var _last_transform := self.transform
@onready var _last_z_index : int = self.z_index
var _highlight_transform_y_offset = 0.0
var _highlight_transform_scale_offset = 1.0
# variables for movement/scaling
const _MOVE_SCALE_SPEED = 2
var need_move := false
signal arrived()
#for interactable cards
var tapped := false
signal card_effect(type : String, value : int)
signal need_discard()

## Manages cardData structure
@export var data:CardData:
	set(value):
		var card_template = self
		data = value
		# check if we actually received any data
		if(data != null):
			# check if we've ever saved data for this card before
			if (_card_hud_elts_dict.is_empty()):
				# find references and save
				_card_hud_elts_dict["Name"] = card_template.find_child("Name")
				_card_hud_elts_dict["EnergyCost"] = card_template.find_child("EnergyCost")
				_card_hud_elts_dict["CardBody"] = card_template.find_child("CardBody")
				#_card_hud_elts_dict["CardType"] = card_template.find_child("CardType")
				_card_hud_elts_dict["ClickButton"] = card_template.find_child("ClickButton")
				_card_hud_elts_dict["LoadContainer"] = card_template.find_child("LoadContainer")
				_card_hud_elts_dict["LoadValue"] = card_template.find_child("LoadValue")
				#_card_hud_elts_dict["CardValue"] = card_template.find_child("CardValue")
			# save to existing references
			_card_hud_elts_dict["Name"].text = data.card_name
			_card_hud_elts_dict["EnergyCost"].text = str(data.card_energy_cost)
			_card_hud_elts_dict["CardBody"].text = data.card_body
			#_card_hud_elts_dict["CardType"].text = data.card_type
			if(data.card_is_clickable):
				_card_hud_elts_dict["ClickButton"].pressed.connect(_on_card_clicked)
			debug_name = data.card_name


## Tweens position to [target_position], and scale to [target_scale_factor]
func move_and_scale(target_position : Vector2, target_scale_factor : float = -1.0) -> void:
	var target_scale : Vector2 = Global.CARD_START_SCALE
	if(target_scale_factor >= 0.0):
		target_scale = target_scale_factor * Global.CARD_START_SCALE
	#TODO: play a start-movement sound
	var move_scale_tween = create_tween()
	move_scale_tween.set_parallel()
	move_scale_tween.tween_property(self, "position", target_position, 1.0/_MOVE_SCALE_SPEED
		).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	move_scale_tween.tween_property(self, "scale", target_scale, 1.0/_MOVE_SCALE_SPEED
		).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	need_move = true
	await move_scale_tween.finished
	need_move = false
	arrived.emit()
	#TODO: play a finished-movemnet sound (?)


## Highlights the card if it isn't already highlighted
func start_highlight() -> void:
	if(need_highlight == true):
		return
	#store variables
	need_highlight = true
	_last_z_index = z_index
	_last_transform = self.transform
	#set new visuals
	var new_transform := Transform2D (
		0, #rotation
		self.scale * _highlight_transform_scale_offset, #scale
		self.skew, #skew
		Vector2(self.position.x, _highlight_transform_y_offset) #position
	)
	_update_appearance(new_transform, _HIGHLIGHT_Z_INDEX)


## Ends highlight for the card
func end_highlight() -> void:
	#store variables
	need_highlight = false
	#reset visuals
	_update_appearance(_last_transform, _last_z_index)


## Updates appearance to match [new_transform] and [new_z_index]
#(helper for highlight functions above)
func _update_appearance(new_transform : Transform2D, new_z_index : int) -> void:
	self.transform = new_transform
	self.z_index = new_z_index


## Updates the properties of the highlight transform by [scale_factor] and [y_offset]
func update_highlight_transform(scale_factor : float, y_offset : float) -> void:
	_highlight_transform_y_offset = y_offset
	_highlight_transform_scale_offset = scale_factor


## Loads card to start value. Returns loaded amount.
func prep_load_card() -> int:
	if(_card_hud_elts_dict["LoadContainer"].visible == false):
		_card_hud_elts_dict["LoadContainer"].visible = true
	_card_hud_elts_dict["LoadValue"].text = str(data.card_load_start_value)
	return data.card_load_start_value


## Unloads/loads card by its card_unload_increment / card_load_increment. Returns new current value.
## If [is_loading] = {true}, we load. Else, we unload.
func load_unload_card_inc(is_loading : bool = false) -> int:
	var curr_value = int(_card_hud_elts_dict["LoadValue"].text)
	#print(data.card_name, curr_value, is_loading)
	if(is_loading):
		curr_value += data.card_load_increment
	elif(!is_loading and curr_value > 0):
		curr_value -= data.card_unload_increment
		card_effect.emit(data.card_load_type, data.card_unload_increment)
	#clamp curr_value
	if(curr_value <= 0):
		curr_value = 0
		if(data.card_discards_when_empty): need_discard.emit()
	_card_hud_elts_dict["LoadValue"].text = str(curr_value)
	return curr_value


## Sets up card for being played in the PlayArea
func handle_play_card() -> void:
	#bail if card can't be played
	if(!data.card_is_persistent): return
	#set the click button visible, if necessary
	if(data.card_is_clickable): _card_hud_elts_dict["ClickButton"].visible = true
	#prep the card if it loads on play
	if(data.card_subtype == "Load"): prep_load_card()


## Handles removing card from the PlayArea
func handle_unplay_card() -> void:
	if(data.card_is_clickable): _card_hud_elts_dict["ClickButton"].visible = false
	if(data.card_is_loadable): _card_hud_elts_dict["LoadContainer"].visible = false


## Handles card being clicked
func _on_card_clicked() -> void:
	#bail if tapped
	if(tapped == true): return
	# do the click stuff
	card_effect.emit("Click",-1)
	if(data.card_subtype == "Load"):
		if(data.card_loads_on_click): load_unload_card_inc(true)
		elif(data.card_unloads_on_click): load_unload_card_inc(false)
	# set card tapped if necessary
	if(data.card_is_repeat_clickable == false): _tap_untap()


## Handles tapping/untapping for cards
func _tap_untap() -> void:
	if(data.card_is_clickable):
		_card_hud_elts_dict["ClickButton"].visible = tapped
	tapped = !tapped


## Handles start-of-turn effects
func handle_turn_start() -> void:
	if(tapped == true): _tap_untap()
	#bail if inappicable
	if(not data.card_is_turn_start): return
	if(data.card_loads_on_start): load_unload_card_inc(true)
	elif(data.card_unloads_on_start): load_unload_card_inc(false)
