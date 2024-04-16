class_name TileArea
extends Control
## This class handles logic for tiles in the Tile area of the bag menu

var BaseRenderTile: PackedScene = load("res://scenes/base_render_tile.tscn")


## This handles when the tiles in the bag menu are clicked
func tile_pressed(tile: BaseRenderTile) -> void:
	get_parent().select_tile(tile.base_tile)
