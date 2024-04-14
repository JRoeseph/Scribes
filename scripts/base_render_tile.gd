class_name BaseRenderTile 
extends Button
## This class is the basis for all the tiles in the game
##
## This class handles the rendering and storage of all the information a tile has

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

## Initializes the class with default values according to Scrababa
func default_init(char: String) -> BaseRenderTile:
	base_tile = BaseTile.new(char, get_default_value(char))
	$Character.text = base_tile.character
	$Value.text = str(base_tile.value)
	return self

var default_vals = {"A":1,"B":3,"C":3,"D":2,"E":1,"F":4,
					"G":2,"H":4,"I":1,"J":8,"K":5,"L":1,
					"M":3,"N":1,"O":1,"P":3,"Q":10,"R":1,
					"S":1,"T":1,"U":1,"V":4,"W":4,"X":8,"Y":4,"Z":10}
func get_default_value(char):
	return default_vals[char]

## Called when a tile is clicked
func _on_button_down() -> void:
	get_parent().tile_pressed(self)
