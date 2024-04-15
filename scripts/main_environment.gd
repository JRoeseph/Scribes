class_name MainEnvironment 
extends Node2D
## The primary gameplay environment
##
## This environment is specifically for the board, placement, etc. It will handle
## tiles, dragging, placing, storing the contents, calculating score, and round information

var BaseRenderTile: PackedScene = load("res://scenes/base_render_tile.tscn")

# TODO: replace these around the project with whatever system Andy is gonna use for resolution
var WINDOW_WIDTH: float = 1920.0
var WINDOW_HEIGHT: float = 1080.0

## The tile being dragged by the user. null if none is active
var grabbed_tile: BaseRenderTile = null:
	get:
		return grabbed_tile
	set(value):
		grabbed_tile = value
		if value == null:
			return
		if rack_tiles.find(value) == -1:
			add_child(grabbed_tile)
			hover_space = $Board.find_hover_space()
			anim_grab_tile_to_hover(true)
		else:
			rack_tiles.erase(value)
			anim_render_rack()
## The array of tiles present on the rack. Does not contain the tile being dragged
var rack_tiles: Array = [] :
	get:
		return rack_tiles
	set(value):
		rack_tiles = value
## The index in rack_tiles grabbed_tile would be placed if let go. Based on grabbed_tile's position
var hover_index: int = -1
## The BoardSpace the cursor is currently over
var hover_space: BoardSpace = null :
	get:
		return hover_space
	set(value):
		if value != hover_space:
			hover_space = value
			anim_grab_tile_to_hover()
## The tween for handling the animation for hovering over tiles. Needs to be stored so it can
## be killed externally if necessary
var grab_tile_hover_tween: Tween = null :
	get:
		return grab_tile_hover_tween
	set(value):
		grab_tile_hover_tween = value
## The object that stores the player data for the run
var player: Player = null :
	get:
		return player
	set(value):
		player = value

## Called when a child BaseTile is clicked 
func tile_pressed(tile: BaseRenderTile) -> void:
	grabbed_tile = tile

## Animation function for locking the grabbed_tile to the grid
func anim_grab_tile_to_hover(is_instant: bool = false) -> void:
	var duration: float = 0.0 if is_instant else 0.2
	if grab_tile_hover_tween != null:
		grab_tile_hover_tween.kill()
	grab_tile_hover_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	if hover_space == null:
		var scale = 12.0 / (ceil((rack_tiles.size() + 1) / 4.0) * 4.0)
		scale = scale if scale <= 1 else 1
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "scale", 
				Vector2(scale,scale), duration)
		return
	else:
		var hover_abs_pos: Vector2 = $Board.get_space_abs_pos(hover_space)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "scale", 
				hover_space.scale, duration)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "position",
				hover_abs_pos - Vector2(75, 75), duration)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "rotation", 
				0, duration)

## Called when the left-mouse button is released and grabbed_tile is not null
func drop_grabbed_tile() -> void:
	if hover_space == null || hover_space.placed_tile != null:
		var space_per_tile: float = WINDOW_WIDTH / (rack_tiles.size()+1)
		var new_hover_index: int = floori(get_viewport().get_mouse_position().x / space_per_tile)
		rack_tiles.insert(new_hover_index, grabbed_tile)
		grabbed_tile.rotation = 0
		grabbed_tile = null
		anim_render_rack()
	else:
		remove_child(grabbed_tile)
		hover_space.place_tile(grabbed_tile)
		grabbed_tile = null
		anim_render_rack()

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Addition of random cells for testing
	for n in range(17):
		rack_tiles.push_back(_temp_generate_random_tile())
		add_child(rack_tiles[n])
	anim_render_rack()
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	anim_grabbed_drag(delta)

## Animation for Tile Dragging
func anim_grabbed_drag(delta: float) -> void:
	if grabbed_tile != null && hover_space == null:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var center_pos: Vector2 = grabbed_tile.position
		var scale = 12.0/(ceil((rack_tiles.size()+1)/4.0)*4.0)
		center_pos.x += 75
		center_pos.y += 75-65*scale
		var velocity: float = center_pos.distance_to(mouse_pos)*10
		var angle: float = mouse_pos.angle_to_point(center_pos)
		var x_diff: float = -cos(angle)*velocity*delta
		var y_diff: float = -sin(angle)*velocity*delta
		if abs(grabbed_tile.position.x - mouse_pos.x) < x_diff:
			grabbed_tile.position.x = mouse_pos.x-75
			grabbed_tile.rotation = 0
		else:
			grabbed_tile.position.x += x_diff
			grabbed_tile.rotation = -atan(cos(angle) * velocity * delta / 10) / (PI / 4)
		if abs(grabbed_tile.position.y - mouse_pos.y) < y_diff:
			grabbed_tile.position.y = mouse_pos.y - (75 - 65 * scale)
		else:
			grabbed_tile.position.y += y_diff

## Animation to render rack texture and it's tiles
func anim_render_rack() -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var count: int = rack_tiles.size() + 1 if grabbed_tile != null else rack_tiles.size()
	var scale: float = 1
	scale = min(1.0, 12.0 / (ceil(count / 4.0) * 4.0))
	tween.parallel().tween_property(get_node("Rack/RackTexture"), 
			"scale", Vector2(scale, scale), 0.2)
	tween.parallel().tween_property(get_node("Rack/RackTexture"), 
			"position", Vector2(0, WINDOW_HEIGHT - 200 * scale), 0.2)
	tween.parallel().tween_property(get_node("Rack/RackTexture"), 
			"size", Vector2(WINDOW_WIDTH * (1 / scale), 200), 0.2)
	if rack_tiles.size() == 0:
		return
	# TODO: Andy will fix this bad code
	if (get_viewport().get_mouse_position().y > WINDOW_HEIGHT - 300 && 
			grabbed_tile != null && hover_index != -1):
		var space_per_tile: float = WINDOW_WIDTH / count
		var left_space: float = space_per_tile / 2 - 75
		var rack_index: int = 0
		for n: int in range(count):
			if hover_index != n:
				tween.parallel().tween_property(rack_tiles[rack_index], 
						"position", 
						Vector2(left_space + space_per_tile * n, 
								WINDOW_HEIGHT - (80 + 120 * scale)), 
						0.2)
				tween.parallel().tween_property(rack_tiles[rack_index], 
						"scale", Vector2(scale,scale), 0.2)
				rack_index += 1
	else:
		var space_per_tile: float = WINDOW_WIDTH / rack_tiles.size()
		var left_space: float = space_per_tile / 2 - 75
		for n: int in range(rack_tiles.size()):
			tween.parallel().tween_property(rack_tiles[n], 
					"position", 
					Vector2(left_space + space_per_tile * n, WINDOW_HEIGHT - (80 + 120 * scale)), 
					0.2)
			tween.parallel().tween_property(rack_tiles[n], "scale", Vector2(scale, scale), 0.2)

var possible_chars: Array = [
	"A","B","C","D","E","F","G","H","I","J","K","L","M",
	"N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
]
var rng = RandomNumberGenerator.new()
func _temp_generate_random_tile():
	var base_tile: BaseRenderTile = BaseRenderTile.instantiate()
	base_tile.default_init(possible_chars[rng.randi_range(0,25)])
	return base_tile

## Input capture when user input occurs
func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if (get_viewport().get_mouse_position().y > $Rack.position.y && 
				grabbed_tile != null && hover_space == null):
			var space_per_tile: float = WINDOW_WIDTH / (rack_tiles.size() + 1)
			var new_hover_index: int = floori(
					get_viewport().get_mouse_position().x / space_per_tile)
			if new_hover_index != hover_index:
				hover_index = new_hover_index
				anim_render_rack()
		elif hover_index != -1 && get_viewport().get_mouse_position().y <= $Rack.position.y:
			hover_index = -1
			anim_render_rack()
	elif event is InputEventMouseButton:
		if grabbed_tile != null && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			drop_grabbed_tile()
	elif event is InputEventKey:
		match(event.physical_keycode):
			KEY_ESCAPE:
				get_tree().quit()
