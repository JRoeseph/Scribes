class_name Word

## Starting location for reading the word on the board
var start_location: Vector2i:
	get:
		return start_location
	set(value):
		start_location = value

## Determines if the word is read horizontally or vertically on the board
var is_horizontal: bool:
	get:
		return is_horizontal
	set(value):
		is_horizontal = value

## Array of tiles the word contains
var tiles: Array[BaseTile]:
	get:
		return tiles
	set(value):
		tiles = value

## The length of the word
var length: int:
	get:
		return tiles.size()
	set(value):
		push_error("Word.length is strictly a read-only value")

## The value of the tiles added together
var play_value: int:
	get:
		var val = 0
		for tile in tiles:
			val += tile.value
		return val


## string override to print words for debugging purposes
func _to_string() -> String:
	var string_rep = ""
	for tile in tiles:
		string_rep += tile.character
	return string_rep + " (" + str(play_value) + ")"


## TODO This method doesn't account for adding on to word length
## We need to figure out a more robust equality method for words 
## (assuming we continue to care about checking word equality)
## Compares multiple word objects for equality
func equals(other: Word) -> bool:
	return is_horizontal == other.is_horizontal && start_location == other.start_location
