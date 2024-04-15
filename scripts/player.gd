class_name Player
## This class stores player data
##
## This class will store the players bag, current score, and other relevant data to runs
## this will not store persistent data across runs

## The list of bag types
enum BagType {
	BASIC
}

## The array that stores the contents of the full bag
var full_bag: Array = [] :
	get:
		return full_bag
	set(value):
		full_bag = value

## The array that stores the contents of the remaining bag
var remaining_bag: Array = [] :
	get:
		return remaining_bag
	set(value):
		remaining_bag = value


## Initializes the bag variable with a given 
func initialize_bag(bag_type: BagType) -> void:
	full_bag.clear()
	remaining_bag.clear()
	var json: JSON = JSON.new()
	var error: Error
	match(bag_type):
		BagType.BASIC:
			var file = FileAccess.open("res://data/basic_bag.json", FileAccess.READ)
			error = json.parse(file.get_as_text())
	if error != OK:
		push_error(str(bag_type) + " json failed to be read")
		return
	for tiles: Array in json.data:
		full_bag.push_back(BaseTile.new(tiles[0], tiles[1], tiles[2], tiles[3], tiles[4]))
		remaining_bag.push_back(BaseTile.new(tiles[0], tiles[1], tiles[2], tiles[3], tiles[4]))


## Constructor
func _init() -> void:
	initialize_bag(BagType.BASIC)


## Sort the bag based on a given sort type
func sort_bag(sort_type: BagMenu.SortType):
	match(sort_type):
		BagMenu.SortType.CHARACTER:
			full_bag.sort_custom(func(a: BaseTile, b: BaseTile): return a.character < b.character)
			remaining_bag.sort_custom(func(a: BaseTile, b: BaseTile): 
				return a.character < b.character)
		BagMenu.SortType.VALUE:
			full_bag.sort_custom(func(a: BaseTile, b: BaseTile): return a.value < b.value)
			remaining_bag.sort_custom(func(a: BaseTile, b: BaseTile): 
				return a.value < b.value)
		BagMenu.SortType.SHAPE:
			full_bag.sort_custom(func(a: BaseTile, b: BaseTile): return a.shape < b.shape)
			remaining_bag.sort_custom(func(a: BaseTile, b: BaseTile): 
				return a.shape < b.shape)
		BagMenu.SortType.COLOR:
			full_bag.sort_custom(func(a: BaseTile ,b: BaseTile): return a.color < b.color)
			remaining_bag.sort_custom(func(a: BaseTile ,b: BaseTile): 
				return a.color < b.color)
		BagMenu.SortType.FONT:
			full_bag.sort_custom(func(a: BaseTile, b: BaseTile): return a.font < b.font)
			remaining_bag.sort_custom(func(a: BaseTile, b: BaseTile): 
				return a.font < b.font)


## Gets a tile and removes it from the remaining bag
func pull_tile() -> BaseTile:
	# TODO: We will need to have one random number generator for all run content and be able to set
	# a seed on it eventually
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var return_tile: BaseTile = remaining_bag[rng.randi_range(0, remaining_bag.size()-1)]
	remaining_bag.erase(return_tile)
	return return_tile
