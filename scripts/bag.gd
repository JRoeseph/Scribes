class_name Bag
extends Button
## This class handles the rendering for the bag
##
## This class handles the rendering and UI logic for the bag, retrieving and sending information
## to the player


## Executed when the button is clicked
func _on_pressed() -> void:
	if !get_parent().is_bag_open:
		get_parent().on_bag_open()
		var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		var new_alpha: Color = $BagSprite.self_modulate
		new_alpha.a = 0.5
		tween.parallel().tween_property($BagSprite, "self_modulate", new_alpha, 0.2)
		tween.parallel().tween_property($BagSprite, "position", Vector2(1380, 540), 0.2)
		tween.parallel().tween_property($BagSprite, "scale", Vector2(6.171, 6.171), 0.2)
