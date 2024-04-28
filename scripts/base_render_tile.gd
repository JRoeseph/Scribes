class_name BaseRenderTile 
extends Button
## This class is the basis for all the tiles in the game
##
## This class handles the rendering and storage of all the information a tile has

## Reference to the control that represents the drag anchor
@export var drag_anchor: Control

## Reference to the tile's sprite
## TODO I want the tile_sprite to rotate separately from the drag anchor, but I don't like
## that other objects are reaching in to this object to tween the tile_sprite. The tile
## should be controlling its own rotation, other objects shouldn't need to know about tile_sprite,
## but if we were to use a "set_rotation" method, then other objects couldn't tween it.
## Find a better solution here.
@export var tile_sprite: Sprite2D

## Reference to the character label
@export var character: Label

## Reference to the value label
@export var value: Label

## The data object for the tile
var base_tile: BaseTile = null :
	get:
		return base_tile
	set(value):
		base_tile = value


## Called when the class is initialized
func init_class(tile: BaseTile) -> BaseRenderTile:
	base_tile = tile
	character.text = base_tile.character
	value.text = str(base_tile.value)
	return self


## Called when a tile is clicked
func _on_button_down() -> void:
	get_parent().tile_pressed(self)
