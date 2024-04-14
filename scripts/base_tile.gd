class_name BaseTile
## The class for the tile data
##
## This class stores the shape, color, font, character, and value of a given tile
## as well as the enums for those values, and any other methods necessary

## The valid shapes for Tiles
enum TileShape {
	Basic,
	half,
	large,
	arrow,
	star,
}
## The valid colors for tiles
enum TileColor {
	Basic,
	Red,
	Orange,
	Yellow,
	Green,
	Blue,
	Purple,
	Black,
	Amber,
}
## The valid fonts for tiles
enum TileFont {
	Basic,
	ASCII,
	ComicSans,
	TimesNewRoman,
	Arial,
}

## The shape of the tile object
var shape: TileShape = TileShape.Basic :
	get:
		return shape
	set(value):
		shape = value
## The color of the tile object
var color: TileColor = TileColor.Basic :
	get:
		return color
	set(value):
		color = value
## The font of the tile object
var font: TileFont = TileFont.Basic :
	get:
		return font
	set(value):
		font = value
## The character(s) of the tile object
var character: String = "" :
	get:
		return character
	set(value):
		character = value
## The value of the tile object
var value: float = 0 :
	get:
		return value
	set(val):
		value = val

func _init(char: String, val: float) -> void:
	character = char
	value = val
