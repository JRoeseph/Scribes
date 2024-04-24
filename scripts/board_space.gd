class_name BoardSpace 
extends Control
## This class represents the spaces on the board
##
## This class captures the grabbed tiles, stores them once placed, will lock them
## at the end of a turn, and can release them if not locked

## Reference to the main environment
@onready var main_env: MainEnvironment = get_parent().main_env

## The tile placed on this space. Null if none
var placed_tile: BaseRenderTile = null :
	get:
		return placed_tile
	set(value):
		placed_tile = value
		
## Whether or not the space is locked for future grabbing
var is_locked: bool = false :
	get:
		return is_locked
	set(value):
		is_locked = value


## Called when the tile on the BoardSpace is pressed
func tile_pressed(tile: BaseRenderTile) -> void:
	if !is_locked:
		remove_child(placed_tile)
		main_env.grabbed_tile = tile
		placed_tile = null


## Places a tile into this space
func place_tile(tile: BaseRenderTile) -> void:
	placed_tile = tile
	var original_position = tile.global_position
	var original_rotation = tile.tile_sprite.rotation
	var original_scale = tile.scale / scale
	add_child(tile)
	main_env.grab_tile_hover_tween.kill()
	# TODO: Tiles jump to the top left corner when double clicking them off the board
	tile.global_position = original_position
	tile.tile_sprite.rotation = original_rotation
	tile.scale = original_scale
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(tile, "position", Vector2(15, 15), 0.2)
	tween.parallel().tween_property(tile, "scale", Vector2(1, 1), 0.2)
	tween.parallel().tween_property(tile.tile_sprite, "rotation", 0, 0.2)
