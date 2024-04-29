class_name MainEnvironment 
extends Node2D
## The primary gameplay environment
##
## This environment is specifically for the board, placement, etc. It will handle
## tiles, dragging, placing, storing the contents, calculating score, and round information

# TODO: GENERAL TODO is to replace any instance of "get_parent" with signals. It appears
# referencing children is in general pretty safe, but parents not as much. OR, if that isn't
# possible with signals, have functions at each layer
var BaseRenderTile: PackedScene = load("res://scenes/base_render_tile.tscn")

# TODO: Look into singleton pattern for main environment

## Reference to the rack node
@export var rack: Control

## Reference to the draggable area for the board
@export var drag_region: Control

## Reference to the texture of the rack
@export var rack_texture: Node

## Reference to the total draggable area for the tiles
@export var tile_drag_area: Control

## Reference to the board node
@export var board: Board

## Reference to the Bag Menu
@export var bag_menu: BagMenu

## Reference to the bag sprite
@export var bag_sprite: Sprite2D

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
			hover_space = board.find_hover_space()
			grabbed_tile.global_position = hover_space.global_position
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

## Whether or not the bag menu is open
var is_bag_open: bool = false :
	get:
		return is_bag_open
	set(value):
		is_bag_open = value

## Should the currently grabbed tile snap to the current hovered space
var should_snap_to_hover: bool :
	get:
		return hover_space != null

## Number of tiles in the rack, accounting for a tile being held
var rack_count: int :
	get:
		return rack_tiles.size() + 1 if is_grabbed_tile_in_rack else rack_tiles.size()

## Current scale of the tiles based on how many tiles are in the rack
var tile_scale: float :
	get:
		return min(1.0, 12.0 / (ceil(rack_count / 4.0) * 4.0))

## Should the rack count grabbed tile as part of rack
var is_grabbed_tile_in_rack: bool :
	get:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var drag_area: Vector2 = drag_region.global_position
		return mouse_pos.y > drag_area.y && grabbed_tile != null


## Called when a child BaseTile is clicked 
func tile_pressed(tile: BaseRenderTile) -> void:
	grabbed_tile = tile


## Animation function for locking the grabbed_tile to the grid
func anim_grab_tile_to_hover(is_instant: bool = false) -> void:
	var duration: float = 0.0 if is_instant else 0.2
	if grab_tile_hover_tween != null:
		grab_tile_hover_tween.kill()
	grab_tile_hover_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	if !should_snap_to_hover:
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "scale", 
				Vector2(tile_scale,tile_scale), duration)
		return
	else:
		var hover_abs_pos: Vector2 = board.get_space_abs_pos(hover_space)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "scale", 
				hover_space.scale, duration)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "position",
				hover_abs_pos - Vector2(75, 75), duration)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile.tile_sprite, "rotation", 
				0, duration)


## Called when the left-mouse button is released and grabbed_tile is not null
func drop_grabbed_tile() -> void:
	if hover_space == null || hover_space.placed_tile != null:
		var space_per_tile: float = rack.size.x / (rack_tiles.size() + 1)
		var new_hover_index: int = floori(get_viewport().get_mouse_position().x / space_per_tile)
		new_hover_index = clamp(new_hover_index, 0, rack_tiles.size())
		rack_tiles.insert(new_hover_index, grabbed_tile)
		grabbed_tile.tile_sprite.rotation = 0
		grabbed_tile = null
		anim_render_rack()
	else:
		remove_child(grabbed_tile)
		hover_space.place_tile(grabbed_tile)
		grabbed_tile = null
		anim_render_rack()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Player.new()
	replenish_rack()
	# These two window lines are just for testing various resolutions
	# we will likely just let the game be full screen in the end
	get_window().size = Vector2i(1440, 810)
	get_window().move_to_center()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	anim_grabbed_drag(delta)


## Animation for Tile Dragging
func anim_grabbed_drag(delta: float) -> void:
	if grabbed_tile != null && hover_space == null:
		var clamped_pos: Vector2 = clamped_mouse_position()
		var center_pos: Vector2 = grabbed_tile.drag_anchor.global_position
		var velocity: float = center_pos.distance_to(clamped_pos) * 10
		var angle: float = clamped_pos.angle_to_point(center_pos)
		var x_diff: float = -cos(angle) * velocity * delta
		var y_diff: float = -sin(angle) * velocity * delta
		if abs(center_pos.x - clamped_pos.x) < x_diff:
			grabbed_tile.position.x = clamped_pos.x - 75
			grabbed_tile.tile_sprite.rotation = 0
		else:
			grabbed_tile.position.x += x_diff
			grabbed_tile.tile_sprite.rotation = -atan(cos(angle) * velocity * delta / 10) / (PI / 4)
		if abs(center_pos.y - clamped_pos.y) < y_diff:
			grabbed_tile.position.y = clamped_pos.y - center_pos.y
		else:
			grabbed_tile.position.y += y_diff


## Calculate a mouse position clamped to the tile drag region
func clamped_mouse_position() -> Vector2:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var clamped_x_pos: float = clamp(mouse_pos.x, tile_drag_area.global_position.x,
			tile_drag_area.global_position.x + tile_drag_area.size.x)
	var clamped_y_pos: float = clamp(mouse_pos.y, tile_drag_area.global_position.y,
			tile_drag_area.global_position.y + tile_drag_area.size.y)
	return Vector2(clamped_x_pos, clamped_y_pos)


## Calculate anchor grab space on grabbed tile
func calculate_tile_drag_anchor() -> Vector2:
	var center_pos: Vector2 = grabbed_tile.position
	center_pos.x += 75
	center_pos.y += 75 - 65 * tile_scale
	return center_pos


## Animation to render rack texture and it's tiles
func anim_render_rack() -> void:
	if rack_tiles.size() == 0:
		return
		
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	anim_render_rack_texture(tween)
	if is_grabbed_tile_in_rack:
		var rack_index: int = 0
		for n: int in range(rack_count):
			if hover_index != n && rack_index < rack_tiles.size():
				anim_render_rack_tile(rack_tiles[rack_index], n, tween)
				rack_index += 1
	else:
		for n: int in range(rack_tiles.size()):
			anim_render_rack_tile(rack_tiles[n], n, tween)


## Applies tween methods to rack texture
func anim_render_rack_texture(tween: Tween):
	tween.parallel().tween_property(rack_texture, 
			"position", Vector2(0, (rack.size.y * (1 - tile_scale))), 0.2)
	tween.parallel().tween_property(rack_texture,
			"size", Vector2(rack.size.x, rack.size.y * tile_scale), 0.2)


## Applies tween methods to given rack tile
func anim_render_rack_tile(tile: Node, index: int, tween: Tween):
	var rack_height: float = rack_texture.global_position.y
	var space_per_tile: float = rack.size.x / rack_count
	var left_space: float = space_per_tile / 2 - 75
	tween.parallel().tween_property(tile, "position", 
			Vector2(left_space + space_per_tile * index, rack_height), 
			0.2)
	tween.parallel().tween_property(tile, "scale", 
			Vector2(tile_scale, tile_scale), 0.2)


## Input capture when user input occurs
func _input(event: InputEvent):
	if event is InputEventKey && event.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
	if is_bag_open:
		return
	if event is InputEventMouseMotion:
		on_mouse_motion_event()
	elif event is InputEventMouseButton:
		if grabbed_tile != null && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			drop_grabbed_tile()


## This function controls how hover_index is impacted by mouse movement
func on_mouse_motion_event():
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	if (mouse_pos.y > drag_region.global_position.y && 
			grabbed_tile != null && !should_snap_to_hover):
		var space_per_tile: float = rack.size.x / (rack_tiles.size() + 1)
		var new_hover_index: int = floori(
				mouse_pos.x / space_per_tile)
		if new_hover_index != hover_index:
			hover_index = new_hover_index
			anim_render_rack()
	elif hover_index != -1 && mouse_pos.y <= drag_region.global_position.y:
		hover_index = -1
		anim_render_rack()


## This function is called when the player opens their bag to view the menu
func on_bag_opened():
	update_bag_open_state(true)


## This function is called when the player closes the bag to view the board
func on_bag_closed():
	update_bag_open_state(false)


## This function updates the visibility of UI elements based on if the bag is open or closed
func update_bag_open_state(open: bool):
	bag_menu.visible = open
	if open:
		bag_menu.render_tiles()
	for n in range(rack_tiles.size()):
		rack_tiles[n].visible = !open
	rack.visible = !open
	is_bag_open = open
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var new_alpha: Color = bag_sprite.self_modulate
	new_alpha.a = 0.5 if open else 1.0
	var new_position = Vector2(1380, 540) if open else Vector2(75, 75)
	var new_scale = Vector2(6.171, 6.171) if open else Vector2(1, 1)
	tween.parallel().tween_property(bag_sprite, "self_modulate", new_alpha, 0.2)
	tween.parallel().tween_property(bag_sprite, "position", new_position, 0.2)
	tween.parallel().tween_property(bag_sprite, "scale", new_scale, 0.2)


func _on_end_turn_button_pressed():
	if verify_valid_play():
		end_turn()


func verify_valid_play() -> bool:
	return true


func end_turn():
	board.lock_tiles()
	replenish_rack()


func replenish_rack():
	for n in range(player.rack_size - rack_count):
		var render_tile: BaseRenderTile = BaseRenderTile.instantiate()
		render_tile.init_class(player.pull_tile())
		rack_tiles.push_back(render_tile)
		add_child(render_tile)
	anim_render_rack()
