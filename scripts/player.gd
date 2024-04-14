class_name Player
## This class stores player data
##
## This class will store the players bag, current score, and other relevant data to runs
## this will not store persistent data across runs

## The list of bag types
enum BagType {
	Basic
}

## The contents of the default bag, formatted as [<char>, <value>, <count>]
var BASIC_BAG = [["A", 1, 9], ["B", 3, 2], ["C", 3, 2], ["D", 2, 4], ["E", 1,12], ["F", 4, 2], 
				 ["G", 2, 3], ["H", 4, 2], ["I", 1, 9], ["J", 8, 1], ["K", 5, 1], ["L", 1, 4], 
				 ["M", 3, 2], ["N", 1, 6], ["O", 1, 6], ["P", 3, 2], ["Q",10, 1], ["R", 1, 8], 
				 ["S", 1, 4], ["T", 1, 6], ["U", 1, 4], ["V", 4, 2], ["W", 4, 2], ["X", 8, 1], 
				 ["Y", 4, 2], ["Z",10, 1], [" ", 0, 2]]

## The array that stores the contents of the bag
var bag: Array = [] :
	get:
		return bag
	set(value):
		bag = value

## Initializes the bag variable with a given 
func initialize_bag(bag_type: BagType) -> void:
	var starting_bag: Array
	bag.clear()
	match(bag_type):
		BagType.Basic:
			starting_bag = BASIC_BAG
	for tiles: Array in starting_bag:
		for n in range(tiles[2]):
			bag.push_back(BaseTile.new(tiles[0], tiles[1]))

func _init() -> void:
	initialize_bag(BagType.Basic)
