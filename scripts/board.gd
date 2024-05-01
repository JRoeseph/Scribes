class_name Board 
extends Node2D
## This class stores the information and renders the board
##
## This class stores a 2d array of all the board spaces, which in turn store
## the tiles on the grid

var BoardSpace: PackedScene = load("res://scenes/board_space.tscn")

const ZOOM_FACTOR_MIN: int = -25
const ZOOM_FACTOR_MAX: int = 7

## Reference to the main environment
@export var main_env: MainEnvironment

## Reference to the area that defines the limits of the board
@export var board_area: Node

## The 2d array that stores the BoardSpaces
var spaces: Array = [] :
	get:
		return spaces
	set(value):
		spaces = value
		
## The power of 1.1 that the spaces zoom to (default size of 180x180)
var zoom_factor: float = 0 :
	get:
		return zoom_factor
	set(value):
		zoom_factor = value
		
## The current scale, calculated using zoom_factor
var current_scale: float = 1 :
	get:
		return pow(1.1, zoom_factor)

## The position of the top-left tile on the board
var top_left_pos: Vector2 = Vector2(0,0) :
	get:
		return top_left_pos
	set(value):
		top_left_pos = value

## The size of the contents of the board
var board_size: Vector2 :
	get:
		return Vector2(spaces.size() * 180 * current_scale,
				spaces[0].size() * 180 * current_scale)
	set(value):
		push_error("Board.board_size is strictly a read-only value")

## The coordinates of the center space for the board. Stored since it will move as the board expands
var center_coords: Vector2i = Vector2i(7,7) :
	get:
		return center_coords
	set(value):
		center_coords = value

## The starting mouse coordinate when dragging the board
var start_drag_pos: Vector2 :
	get:
		return start_drag_pos
	set(value):
		start_drag_pos = value

## The starting mouse coordinate when dragging the board
var last_click_position: Vector2 :
	get:
		return last_click_position
	set(value):
		last_click_position = value

## The collection of words played on the current turn
var current_words: Array[Word] :
	get:
		return current_words
	set(value):
		current_words = value


## Called when the node enters the scene tree for the first time.
func _ready():
	for x: int in range(15):
		spaces.push_back([])
		for y: int in range(15):
			var board_space: BoardSpace = BoardSpace.instantiate()
			add_child(board_space)
			spaces[x].push_back(board_space)
	build_board()


## Builds the initial conditions for the board to be built
func build_board():
	var x_scale: float = board_area.size.x / (spaces.size() * 180.0)
	var y_scale: float = board_area.size.y / (spaces[0].size() * 180.0)
	var new_scale: float = x_scale if x_scale < y_scale else y_scale
	zoom_factor = round(log(new_scale) / log(1.1))
	var drag_area_center: Vector2 = board_area.position + board_area.size / 2
	var x_offset: float = drag_area_center.x - (spaces.size() * 180.0 * new_scale) / 2
	var y_offset: float = drag_area_center.y - (spaces[0].size() * 180.0 * new_scale) / 2
	
	anim_render_board(Vector2(x_offset, y_offset))
	top_left_pos = Vector2(x_offset, y_offset)


## Animates the board to its new position and size
func anim_render_board(starting_pos: Vector2):
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	for x: int in range(spaces.size()):
		for y: int in range(spaces[0].size()):
			tween.parallel().tween_property(spaces[x][y], 
					"scale", Vector2(current_scale, current_scale), 0.2)
			tween.parallel().tween_property(spaces[x][y], 
					"position", 
					Vector2(starting_pos.x + 180 * current_scale * x, 
							starting_pos.y + 180 * current_scale * y), 
					0.2)


## Returns the board space the mouse cursor is over, returns null if none
func find_hover_space() -> BoardSpace:
	if main_env.is_grabbed_tile_in_rack:
		return null
	var abs_tl = self.position + top_left_pos
	var board_rect: Rect2 = Rect2(abs_tl,
		Vector2(spaces.size() * 180 * current_scale,
				spaces[0].size() * 180 * current_scale))
	if board_rect.has_point(get_global_mouse_position()):
		var rel_mou_pos: Vector2 = get_global_mouse_position() - abs_tl
		var x: int = floori(rel_mou_pos.x / (180 * current_scale))
		var y: int = floori(rel_mou_pos.y / (180 * current_scale))
		if x < 0 || y < 0 || x >= spaces.size() || y >= spaces[0].size():
			return null
		return spaces[x][y]
	return null


## Ensures any part of the board is in the center of the screen by making it so the edges can't
## go across the center in the opposite direction
func ensure_board_centered():
	var drag_area_center: Vector2 = board_area.position + board_area.size / 2
	if self.position.x + top_left_pos.x + board_size.x < drag_area_center.x:
		self.position.x = drag_area_center.x - top_left_pos.x - board_size.x
	elif self.position.x + top_left_pos.x > drag_area_center.x:
		self.position.x = drag_area_center.x - top_left_pos.x
	if self.position.y + top_left_pos.y + board_size.y < drag_area_center.y:
		self.position.y = drag_area_center.y - top_left_pos.y - board_size.y
	elif self.position.y + top_left_pos.y > drag_area_center.y:
		self.position.y = drag_area_center.y - top_left_pos.y


## Captures input for handling interactions with the board
func _input(event: InputEvent):
	if main_env.is_bag_open:
		return
	if event is InputEventMouseMotion:
		on_mouse_motion_event(event)
	elif event is InputEventMouseButton:
		match(event.button_index):
			MOUSE_BUTTON_WHEEL_UP:
				change_zoom(1)
			MOUSE_BUTTON_WHEEL_DOWN:
				change_zoom(-1)
			MOUSE_BUTTON_LEFT:
				start_drag_pos = position
				last_click_position = get_global_mouse_position()


## This function controls dragging the board and setting the hover_space
func on_mouse_motion_event(event: InputEvent):
	if event.get_pressure() == 1 && main_env.grabbed_tile == null:
		var mouse_offset = get_global_mouse_position() - last_click_position
		position = start_drag_pos + mouse_offset
		ensure_board_centered()
	elif event.get_pressure() == 1:
		var hover_space: BoardSpace = find_hover_space()
		if hover_space == null || hover_space.placed_tile != null:
			main_env.hover_space = null
		else:
			main_env.hover_space = hover_space


## This function changes the current zoom level
func change_zoom(zoom_in: float):
	if (main_env.grabbed_tile != null || 
			((zoom_factor >= ZOOM_FACTOR_MAX && zoom_in > 0) ||
			(zoom_factor <= ZOOM_FACTOR_MIN && zoom_in < 0))):
				return
				
	zoom_factor += zoom_in
	var mouse_to_topleft_pos: Vector2 = (top_left_pos + self.position 
			- get_global_mouse_position())
	var position_factor = pow(1.1, zoom_in)
	var zoomed_pos = mouse_to_topleft_pos * position_factor
	var offset: Vector2 = zoomed_pos - mouse_to_topleft_pos
	top_left_pos += offset
	anim_render_board(top_left_pos)


## Returns the absolute position relative to the window of a specific space
func get_space_abs_pos(space: BoardSpace) -> Vector2:
	return space.global_position + Vector2(1, 1) * 90 * current_scale


## At the end of the turn, locks the played tiles in place
func lock_tiles():
	current_words.clear()
	for x: int in range(spaces.size()):
		for y: int in range(spaces[0].size()):
			if spaces[x][y].placed_tile != null && !spaces[x][y].is_locked:
				calculate_words(x, y, true)
				calculate_words(x, y, false)
				spaces[x][y].is_locked = true


## During scoring, calculate the tiles that make up newly played words
func calculate_words(x: int, y: int, is_horizontal: bool):
	var x_index = x
	var y_index = y
	x_index -= 1 if is_horizontal else 0
	y_index -= 1 if !is_horizontal else 0
		
	while x_index > 0  && y_index > 0 && spaces[x_index][y_index].placed_tile != null:
		if !spaces[x_index][y_index].is_locked:
			return
		x_index -= 1 if is_horizontal else 0
		y_index -= 1 if !is_horizontal else 0
		
	x_index += 1 if is_horizontal else 0
	y_index += 1 if !is_horizontal else 0
	var new_word = Word.new()
	new_word.is_horizontal = is_horizontal
	new_word.start_location = Vector2i(x_index, y_index)
	while spaces[x_index][y_index].placed_tile != null:
		new_word.tiles.push_back(spaces[x_index][y_index].placed_tile.base_tile)
		x_index += 1 if is_horizontal else 0
		y_index += 1 if !is_horizontal else 0
	if (current_words.any(func(word): return new_word.equals(word)) ||
			new_word.tiles.size() < 2):
		return
	
	current_words.push_back(new_word)
	print(new_word)

