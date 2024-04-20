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
@onready var main_env: Node = get_parent()

## Reference to the area that defines the limits of the board
@onready var board_area: Node = $"../BoardArea"

##Reference to the texture of the rack
@onready var rack_texture: Node = $"../Rack/RackTexture"

## The 2d array that stores the BoardSpaces
var spaces: Array = [] :
	get:
		return spaces
	set(value):
		spaces = value
		
## The power of 1.1 that the spaces zoom to (default size of 180x180
var zoom_factor: int = 0 :
	get:
		return zoom_factor
	set(value):
		zoom_factor = value
		
## The position of the top-left tile on the board
var top_left_pos: Vector2 = Vector2(0,0) :
	get:
		return top_left_pos
	set(value):
		top_left_pos = value
		
## The size of the contents of the board
var board_size: Vector2 :
	get:
		return Vector2(spaces.size() * 180 * pow(1.1, zoom_factor),
				spaces[0].size() * 180 * pow(1.1, zoom_factor))
	set(value):
		push_error("Board.board_size is strictly a read-only value")
		
## The coordinates of the center space for the board. Stored since it will move as the board expands
var center_coords: Vector2i = Vector2i(7,7) :
	get:
		return center_coords
	set(value):
		center_coords = value


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
	var current_scale: float = pow(1.1, zoom_factor)
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
	if get_global_mouse_position().y > rack_texture.global_position.y:
		return null
	var abs_tl = self.position + top_left_pos
	var current_scale: float = pow(1.1, zoom_factor)
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
		if event.get_pressure() == 1 && main_env.grabbed_tile == null:
			self.position += event.relative
			ensure_board_centered()
		elif event.get_pressure() == 1:
			var hover_space: BoardSpace = find_hover_space()
			if hover_space == null || hover_space.placed_tile != null:
				main_env.hover_space = null
			else:
				main_env.hover_space = hover_space
	elif event is InputEventMouseButton:
		match(event.button_index):
			MOUSE_BUTTON_WHEEL_UP:
				if main_env.grabbed_tile == null && zoom_factor < ZOOM_FACTOR_MAX:
					zoom_factor += 1
					var mouse_to_topleft_pos: Vector2 = (top_left_pos + self.position 
							- get_global_mouse_position())
					var offset: Vector2 = (mouse_to_topleft_pos * 1.1) - mouse_to_topleft_pos
					top_left_pos += offset
					anim_render_board(top_left_pos)
			MOUSE_BUTTON_WHEEL_DOWN:
				if main_env.grabbed_tile == null && zoom_factor > ZOOM_FACTOR_MIN:
					zoom_factor -= 1
					var mouse_to_topleft_pos: Vector2 = (top_left_pos + self.position 
							- get_global_mouse_position())
					var offset: Vector2 = (mouse_to_topleft_pos / (1.1)) - mouse_to_topleft_pos
					top_left_pos += offset
					anim_render_board(top_left_pos)


## Returns the absolute position relative to the window of a specific space
func get_space_abs_pos(space: BoardSpace) -> Vector2:
	return space.position + position + Vector2(1, 1) * 90 * pow(1.1, zoom_factor)
