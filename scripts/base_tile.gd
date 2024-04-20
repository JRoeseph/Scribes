class_name BaseTile
## The class for the tile data
##
## This class stores the shape, color, font, character, and value of a given tile
## as well as the enums for those values, and any other methods necessary

## The valid shapes for Tiles
enum TileShape {
	BASIC = 0,
	ARROW = 1,
	STAR = 2,
	HALF = 3,
	LARGE = 4,
}

## A dictionary to get the string variant of the TileShape enum
const TILE_SHAPE_TO_STRING: Dictionary = {
	TileShape.BASIC: "Basic",
	TileShape.ARROW: "Arrow",
	TileShape.STAR: "Star",
	TileShape.HALF: "Half",
	TileShape.LARGE: "Large",
}
		
## The valid colors for tiles
enum TileColor {
	BASIC = 0,
	RED = 1,
	ORANGE = 2,
	YELLOW = 3,
	GREEN = 4,
	BLUE = 5,
	PURPLE = 6,
	BLACK = 7,
	AMBER = 8,
}

## A dictionary to get the string variant of the TileColor enum
const TILE_COLOR_TO_STRING: Dictionary = {
	TileColor.BASIC: "Basic",
	TileColor.RED: "Red",
	TileColor.ORANGE: "Orange",
	TileColor.YELLOW: "Yellow",
	TileColor.GREEN: "Green",
	TileColor.BLUE: "Blue",
	TileColor.PURPLE: "Purple",
	TileColor.BLACK: "Black",
	TileColor.AMBER: "Amber",
}

## The valid fonts for tiles
enum TileFont {
	BASIC = 0,
	ARIAL = 1,
	TIMES_NEW_ROMAN = 2,
	COMIC_SANS = 3,
	ASCII = 4,
}

## A dictionary to get the string variant of the TileFont enum
const TILE_FONT_TO_STRING: Dictionary = {
	TileFont.BASIC: "Basic",
	TileFont.ARIAL: "Arial",
	TileFont.TIMES_NEW_ROMAN: "Times New Roman",
	TileFont.COMIC_SANS: "Comic Sans",
	TileFont.ASCII: "ASCII",
}

## The shape of the tile object
var shape: TileShape = TileShape.BASIC :
	get:
		return shape
	set(value):
		shape = value

## The color of the tile object
var color: TileColor = TileColor.BASIC :
	get:
		return color
	set(value):
		color = value

## The font of the tile object
var font: TileFont = TileFont.BASIC :
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


## This function returns the corresponding TileShape from a string
func string_to_shape(string: String) -> TileShape:
	match(string):
		"BASIC":
			return TileShape.BASIC
		"HALF":
			return TileShape.HALF
		"LARGE":
			return TileShape.LARGE
		"ARROW":
			return TileShape.ARROW
		"STAR":
			return TileShape.STAR
	return TileShape.BASIC


## This function returns the corresponding TileColor from a string
func string_to_color(string: String) -> TileColor:
	match(string):
		"BASIC":
			return TileColor.BASIC
		"RED":
			return TileColor.RED
		"ORANGE":
			return TileColor.ORANGE
		"YELLOW":
			return TileColor.YELLOW
		"GREEN":
			return TileColor.GREEN
		"BLUE":
			return TileColor.BLUE
		"PURPLE":
			return TileColor.PURPLE
		"BLACK":
			return TileColor.BLACK
		"AMBER":
			return TileColor.AMBER
	return TileColor.BASIC


## This function returns the corresponding TileFont from a string
func string_to_font(string: String) -> TileFont:
	match(string):
		"BASIC":
			return TileFont.BASIC
		"ASCII":
			return TileFont.ASCII
		"COMIC_SANS":
			return TileFont.COMIC_SANS
		"TIMES_NEW_ROMAN":
			return TileFont.TIMES_NEW_ROMAN
		"ARIAL":
			return TileFont.ARIAL
	return TileFont.BASIC


# Constructor
func _init(p_char: String, val: float, shap = TileShape.BASIC, 
		col = TileColor.BASIC, fnt = TileFont.BASIC) -> void:
	if shap is TileShape && col is TileColor && fnt is TileFont:
		character = p_char
		value = val
		shape = shap
		color = col
		font = fnt
	elif shap is String && col is String && fnt is String:
		character = p_char
		value = val
		shape = string_to_shape(shap)
		color = string_to_color(col)
		font = string_to_font(fnt)
	else:
		push_error("Invalid BaseTile constructor arguments")
