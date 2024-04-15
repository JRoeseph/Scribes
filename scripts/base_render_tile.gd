class_name BaseRenderTile 
extends Button
## This class is the basis for all the tiles in the game
##
## This class handles the rendering and storage of all the information a tile has

## The data object for the tile
var base_tile: BaseTile = null :
	get:
		return base_tile
	set(value):
		base_tile = value


## Called when the class is initialized
func init_class(tile: BaseTile) -> BaseRenderTile:
	base_tile = tile
	$Character.text = base_tile.character
	$Value.text = str(base_tile.value)
	return self

## Called when a tile is clicked
func _on_button_down() -> void:
	get_parent().tile_pressed(self)
