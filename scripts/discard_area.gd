class_name DiscardArea extends Control
## This class stores the information and renders the discard area
##
## This class stores the 2d array of tiles to be discarded, and renders them in
## the designated area on the right. Also does the animation for placing tiles
## there and removing them on turn end

## Reference to the main environment
@onready var main_env: MainEnvironment = get_parent()

## Whether or not the space is locked for future grabbing
var tile_array: Array = [] :
	get:
		return tile_array
	set(value):
		tile_array = value

## The global pos of the grabbed tile
var grab_global_pos: Vector2 = Vector2(0, 0) :
	get:
		return grab_global_pos
	set(value):
		grab_global_pos = value


## The method called when a tile in the discard area is clicked
func tile_pressed(tile: BaseRenderTile) -> void:
	grab_global_pos = tile.global_position
	tile_array.erase(tile)
	remove_child(tile)
	main_env.grabbed_tile = tile
	render_tiles()


## The method called when a tile is dropped in the discard area
func add_tile(tile: BaseRenderTile) -> void:
	var original_position = tile.global_position
	var original_rotation = tile.tile_sprite.rotation
	var original_scale = tile.scale / scale
	tile_array.push_back(tile)
	add_child(tile)
	if main_env.grab_tile_hover_tween != null:
		main_env.grab_tile_hover_tween.kill()
	# TODO: Tiles jump to the top left corner when double clicking them off the board
	tile.global_position = original_position
	tile.tile_sprite.rotation = original_rotation
	tile.scale = original_scale
	render_tiles()


## The method called to create and render the tiles in the discard area
func render_tiles() -> void:
	var columns: int = 1
	while tile_array.size() > columns*columns*4:
		columns += 1
	var curr_col: int = 0
	var curr_row: int = 0
	var scale: float = 1.0/(columns as float)
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	for tile: BaseRenderTile in tile_array:
		var x_pos: float = curr_col*150*scale+10-(75-75*scale)
		var y_pos: float = curr_row*150*scale+150-(75-75*scale)
		tween.parallel().tween_property(tile, "position", Vector2(x_pos, y_pos), 0.2)
		tween.parallel().tween_property(tile, "scale", Vector2(scale, scale), 0.2)
		tween.parallel().tween_property(tile.tile_sprite, "rotation", 0, 0.2)
		curr_col += 1
		if curr_col == columns:
			curr_col = 0
			curr_row += 1


## The method to clear and animate out the tiles
func clear_tiles() -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	for tile: BaseRenderTile in tile_array:
		tween.parallel().chain().tween_property(tile, "position", Vector2(-1740, -50), 0.2)
		tween.parallel().tween_property(tile, "scale", Vector2(0, 0), 0.2)
	await tween.finished
	for tile: BaseRenderTile in tile_array:
		remove_child(tile)
		main_env.add_tile_to_remaining_bag(tile.base_tile)
	tile_array = []

