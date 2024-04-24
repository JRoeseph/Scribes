class_name Bag
extends Button
## This class handles the rendering for the bag
##
## This class handles the rendering and UI logic for the bag, retrieving and sending information
## to the player


## Executed when the button is clicked
func _on_pressed() -> void:
	if !get_parent().is_bag_open:
		get_parent().on_bag_opened()
