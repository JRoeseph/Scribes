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

var TILE_SHAPE_TO_STRING: Dictionary = {
	TileShape.BASIC: "Basic",
	TileShape.ARROW: "Arrow",
	TileShape.STAR: "Star",
	TileShape.HALF: "Half",
	TileShape.LARGE: "Large",
} :
	get:
		return TILE_SHAPE_TO_STRING
	set(val):
		push_error("TILE_SHAPE_TO_STRING is constant")
		
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

var TILE_COLOR_TO_STRING: Dictionary = {
	TileColor.BASIC: "Basic",
	TileColor.RED: "Red",
	TileColor.ORANGE: "Orange",
	TileColor.YELLOW: "Yellow",
	TileColor.GREEN: "Green",
	TileColor.BLUE: "Blue",
	TileColor.PURPLE: "Purple",
	TileColor.BLACK: "Black",
	TileColor.AMBER: "Amber",
} :
	get:
		return TILE_COLOR_TO_STRING
	set(val):
		push_error("TILE_COLOR_TO_STRING is constant")

## The valid fonts for tiles
enum TileFont {
	BASIC = 0,
	ARIAL = 1,
	TIMES_NEW_ROMAN = 2,
	COMIC_SANS = 3,
	ASCII = 4,
}

var TILE_FONT_TO_STRING: Dictionary = {
	TileFont.BASIC: "Basic",
	TileFont.ARIAL: "Arial",
	TileFont.TIMES_NEW_ROMAN: "Times New Roman",
	TileFont.COMIC_SANS: "Comic Sans",
	TileFont.ASCII: "ASCII",
} :
	get:
		return TILE_FONT_TO_STRING
	set(val):
		push_error("TILE_FONT_TO_STRING is constant")

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


func _init(char: String, val: float, shap = TileShape.BASIC, 
		col = TileColor.BASIC, fnt = TileFont.BASIC) -> void:
	if shap is TileShape && col is TileColor && fnt is TileFont:
		character = char
		value = val
		shape = shap
		color = col
		font = fnt
	elif shap is String && col is String && fnt is String:
		character = char
		value = val
		match(shap):
			"BASIC":
				shape = TileShape.BASIC
			"HALF":
				shape = TileShape.HALF
			"LARGE":
				shape = TileShape.LARGE
			"ARROW":
				shape = TileShape.ARROW
			"STAR":
				shape = TileShape.STAR
		match(col):
			"BASIC":
				color = TileColor.BASIC
			"RED":
				color = TileColor.RED
			"ORANGE":
				color = TileColor.ORANGE
			"YELLOW":
				color = TileColor.YELLOW
			"GREEN":
				color = TileColor.GREEN
			"BLUE":
				color = TileColor.BLUE
			"PURPLE":
				color = TileColor.PURPLE
			"BLACK":
				color = TileColor.BLACK
			"AMBER":
				color = TileColor.AMBER
		match(fnt):
			"BASIC":
				font = TileFont.BASIC
			"ASCII":
				font = TileFont.ASCII
			"COMIC_SANS":
				font = TileFont.COMIC_SANS
			"TIMES_NEW_ROMAN":
				font = TileFont.TIMES_NEW_ROMAN
			"ARIAL":
				font = TileFont.ARIAL
	else:
		push_error("Invalid BaseTile constructor arguments")
