class_name BagMenu
extends Control
## This class handles all logic for the bag menu

var BaseRenderTile: PackedScene = load("res://scenes/base_render_tile.tscn")

## The possible ways to sort
enum SortType {
	CHARACTER,
	VALUE,
	SHAPE,
	COLOR,
	FONT,
}

## Reference to the tile area
@export var tile_area : Control

## A dictionary between the BaseTile objects and the BaseRenderTile counterparts in the bag
var tile_to_render_tile: Dictionary = {} 

## The current way to sort the bag
var sort_type: SortType = SortType.CHARACTER :
	get:
		return sort_type
	set(value):
		sort_type = value

## Whether we are looking at the full bag (true) or remaining bag (false)
var is_view_full: bool = false :
	get:
		return is_view_full
	set(value):
		is_view_full = value

## The tile being previewed in the bottom left of the bag menu
var preview_tile: BaseRenderTile = null :
	get:
		return preview_tile
	set(value):
		preview_tile = value


## Executed when the close button is clicked
func _on_close_button_pressed() -> void:
	while tile_area.get_child_count() > 0:
		var tile: BaseRenderTile = tile_area.get_child(0)
		tile_area.remove_child(tile)
	if preview_tile != null:
		remove_child(preview_tile)
	$TilePreview/CharacterLabel.text = "Character: " 
	$TilePreview/ValueLabel.text = "Value : "
	$TilePreview/ShapeLabel.text = "Shape: "
	$TilePreview/ColorLabel.text = "Color: "
	$TilePreview/FontLabel.text = "Font: "
	tile_to_render_tile.clear()
	get_parent().on_bag_closed()


## Render tiles initially when bag menu is opened
func render_tiles() -> void:
	get_parent().player.sort_bag(sort_type)
	var bag: Array = get_parent().player.full_bag if is_view_full else (
		get_parent().player.remaining_bag)
	var row_size: int = ceili(pow(bag.size(), 0.5))
	var tile_size: float = tile_area.size.x / row_size as float
	var x_pos: int = 0
	var y_pos: int = 0
	for tile: BaseTile in bag:
		var new_tile: BaseRenderTile = BaseRenderTile.instantiate()
		new_tile.init_class(tile)
		tile_area.add_child(new_tile)
		tile_to_render_tile[tile] = new_tile
		new_tile.position = Vector2(x_pos * tile_size - 25, y_pos * tile_size - 25)
		new_tile.scale = Vector2(tile_size / 200, tile_size / 200)
		x_pos += 1
		if x_pos == row_size:
			x_pos = 0
			y_pos += 1


## Reorders the tiles
func reorder_tiles() -> void:
	get_parent().player.sort_bag(sort_type)
	var bag: Array = get_parent().player.full_bag if is_view_full else (
		get_parent().player.remaining_bag)
	var row_size: int = ceili(pow(bag.size(), 0.5))
	var tile_size: float = tile_area.size.x / row_size as float
	var x_pos: int = 0
	var y_pos: int = 0
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	for tile: BaseTile in bag:
		var new_tile: BaseRenderTile = tile_to_render_tile[tile]
		tween.parallel().tween_property(new_tile, 
				"position", 
				Vector2(x_pos*tile_size - 25, y_pos * tile_size - 25),
				0.2)
		tween.parallel().tween_property(new_tile, 
				"scale", 
				Vector2(tile_size / 200, tile_size / 200),
				0.2)
		x_pos += 1
		if x_pos == row_size:
			x_pos = 0
			y_pos += 1


## Resets and re-renders tiles
func rerender_tiles() -> void:
	while true:
		var tile: BaseRenderTile = tile_area.get_child(0)
		if tile == null:
			break
		tile_area.remove_child(tile)
	render_tiles()


## On pressed, change the tiles to remaining tiles instead of all
func _on_view_remaining_pressed() -> void:
	if is_view_full:
		is_view_full = false
		rerender_tiles()


## On pressed, change the tiles to all tiles instead of remaining
func _on_view_all_pressed() -> void:
	if !is_view_full:
		is_view_full = true
		rerender_tiles()


func _on_sort_shape_pressed():
	if sort_type != SortType.SHAPE:
		sort_type = SortType.SHAPE
		reorder_tiles()


func _on_sort_value_pressed():
	if sort_type != SortType.VALUE:
		sort_type = SortType.VALUE
		reorder_tiles()


func _on_sort_character_pressed():
	if sort_type != SortType.CHARACTER:
		sort_type = SortType.CHARACTER
		reorder_tiles()


func _on_sort_color_pressed():
	if sort_type != SortType.COLOR:
		sort_type = SortType.COLOR
		reorder_tiles()


func _on_sort_font_pressed():
	if sort_type != SortType.FONT:
		sort_type = SortType.FONT
		reorder_tiles()

func select_tile(tile: BaseTile):
	preview_tile = BaseRenderTile.instantiate()
	preview_tile.init_class(tile)
	add_child(preview_tile)
	preview_tile.scale = Vector2(2, 2)
	preview_tile.position = Vector2(50 + 75, 720 + 75)
	$TilePreview/CharacterLabel.text = "Character: " + tile.character
	$TilePreview/ValueLabel.text = "Value : " + str(tile.value)
	$TilePreview/ShapeLabel.text = "Shape: " + BaseTile.TILE_SHAPE_TO_STRING[tile.shape]
	$TilePreview/ColorLabel.text = "Color: " + BaseTile.TILE_COLOR_TO_STRING[tile.color]
	$TilePreview/FontLabel.text = "Font: " + BaseTile.TILE_FONT_TO_STRING[tile.font]
