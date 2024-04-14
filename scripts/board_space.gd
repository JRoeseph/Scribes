class_name BoardSpace 
extends Control
## This class represents the spaces on the board
##
## This class captures the grabbed tiles, stores them once placed, will lock them
## at the end of a turn, and can release them if not locked

## The tile placed on this space. Null if none
var placed_tile: BaseTile = null :
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
func tile_pressed(tile: BaseTile) -> void:
	if !is_locked:
		remove_child(placed_tile)
		get_parent().get_parent().grabbed_tile = tile
		placed_tile = null

## Places a tile into this space
func place_tile(tile: BaseTile) -> void:
	placed_tile = tile
	add_child(placed_tile)
	get_parent().get_parent().grab_tile_hover_tween.kill()
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	#tween.parallel().tween_property(placed_tile, "position", Vector2(15, 15), 0)
	#tween.parallel().tween_property(placed_tile, "scale", Vector2(1, 1), 0)
	#tween.parallel().tween_property(placed_tile, "rotation", 0, 0)
	placed_tile.position = Vector2(15,15)
	placed_tile.scale = Vector2(1,1)
	placed_tile.rotation = 0
