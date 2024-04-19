class_name MainEnvironment 
extends Node2D
## The primary gameplay environment
##
## This environment is specifically for the board, placement, etc. It will handle
## tiles, dragging, placing, storing the contents, calculating score, and round information

# TODO: GENERAL TODO is to replace any instance of "get_parent" with signals. It appears
# referencing children is in general pretty safe, but parents not as much. OR, if that isn't
# possible with signals, have functions at each layer
var BaseRenderTile: PackedScene = load("res://scenes/base_render_tile.tscn")

## Reference to the draggable area for the board
@onready var drag_region: Control = $Rack/DragArea

## The tile being dragged by the user. null if none is active
var grabbed_tile: BaseRenderTile = null:
	get:
		return grabbed_tile
	set(value):
		grabbed_tile = value
		if value == null:
			return
		if rack_tiles.find(value) == -1:
			add_child(grabbed_tile)
			hover_space = $Board.find_hover_space()
			anim_grab_tile_to_hover(true)
		else:
			rack_tiles.erase(value)
			anim_render_rack()

## The array of tiles present on the rack. Does not contain the tile being dragged
var rack_tiles: Array = [] :
	get:
		return rack_tiles
	set(value):
		rack_tiles = value

## The index in rack_tiles grabbed_tile would be placed if let go. Based on grabbed_tile's position
var hover_index: int = -1

## The BoardSpace the cursor is currently over
var hover_space: BoardSpace = null :
	get:
		return hover_space
	set(value):
		if value != hover_space:
			hover_space = value
			anim_grab_tile_to_hover()



## The tween for handling the animation for hovering over tiles. Needs to be stored so it can
## be killed externally if necessary
var grab_tile_hover_tween: Tween = null :
	get:
		return grab_tile_hover_tween
	set(value):
		grab_tile_hover_tween = value

## The object that stores the player data for the run
var player: Player = null :
	get:
		return player
	set(value):
		player = value

## Whether or not the bag menu is open
var is_bag_open: bool = false :
	get:
		return is_bag_open
	set(value):
		is_bag_open = value


## Called when a child BaseTile is clicked 
func tile_pressed(tile: BaseRenderTile) -> void:
	grabbed_tile = tile


## Animation function for locking the grabbed_tile to the grid
func anim_grab_tile_to_hover(is_instant: bool = false) -> void:
	var duration: float = 0.0 if is_instant else 0.2
	if grab_tile_hover_tween != null:
		grab_tile_hover_tween.kill()
	grab_tile_hover_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	if hover_space == null:
		var tile_scale = 12.0 / (ceil((rack_tiles.size() + 1) / 4.0) * 4.0)
		tile_scale = tile_scale if tile_scale <= 1 else 1
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "scale", 
				Vector2(tile_scale,tile_scale), duration)
		return
	else:
		var hover_abs_pos: Vector2 = $Board.get_space_abs_pos(hover_space)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "scale", 
				hover_space.scale, duration)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "position",
				hover_abs_pos - Vector2(75, 75), duration)
		grab_tile_hover_tween.parallel().tween_property(grabbed_tile, "rotation", 
				0, duration)


## Called when the left-mouse button is released and grabbed_tile is not null
func drop_grabbed_tile() -> void:
	if hover_space == null || hover_space.placed_tile != null:
		var space_per_tile: float = $Rack.size.x / (rack_tiles.size() + 1)
		var new_hover_index: int = floori(get_viewport().get_mouse_position().x / space_per_tile)
		rack_tiles.insert(new_hover_index, grabbed_tile)
		grabbed_tile.rotation = 0
		grabbed_tile = null
		anim_render_rack()
	else:
		remove_child(grabbed_tile)
		hover_space.place_tile(grabbed_tile)
		grabbed_tile = null
		anim_render_rack()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Player.new()
	for n in range(player.rack_size):
		var render_tile: BaseRenderTile = BaseRenderTile.instantiate()
		render_tile.init_class(player.pull_tile())
		rack_tiles.push_back(render_tile)
		add_child(rack_tiles[n])
	anim_render_rack()
	get_window().size = Vector2i(1440, 810)
	get_window().move_to_center()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	anim_grabbed_drag(delta)


## Animation for Tile Dragging
func anim_grabbed_drag(delta: float) -> void:
	if grabbed_tile != null && hover_space == null:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var center_pos: Vector2 = grabbed_tile.position
		var tile_scale = 12.0/(ceil((rack_tiles.size() + 1) / 4.0) * 4.0)
		center_pos.x += 75
		center_pos.y += 75 - 65 * tile_scale
		var velocity: float = center_pos.distance_to(mouse_pos) * 10
		var angle: float = mouse_pos.angle_to_point(center_pos)
		var x_diff: float = -cos(angle) * velocity * delta
		var y_diff: float = -sin(angle) * velocity * delta
		if abs(grabbed_tile.position.x - mouse_pos.x) < x_diff:
			grabbed_tile.position.x = mouse_pos.x - 75
			grabbed_tile.rotation = 0
		else:
			grabbed_tile.position.x += x_diff
			grabbed_tile.rotation = -atan(cos(angle) * velocity * delta / 10) / (PI / 4)
		if abs(grabbed_tile.position.y - mouse_pos.y) < y_diff:
			grabbed_tile.position.y = mouse_pos.y - (75 - 65 * tile_scale)
		else:
			grabbed_tile.position.y += y_diff


## Animation to render rack texture and it's tiles
func anim_render_rack() -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var count: int = rack_tiles.size() + 1 if grabbed_tile != null else rack_tiles.size()
	var tile_scale: float = min(1.0, 12.0 / (ceil(count / 4.0) * 4.0))
	var rack_size: Vector2 = $Rack.size
	tween.parallel().tween_property($Rack/RackTexture, 
			"position", Vector2(0, (rack_size.y * (1 - tile_scale))), 0.2)
	tween.parallel().tween_property($Rack/RackTexture,
			"size", Vector2(rack_size.x, rack_size.y * tile_scale), 0.2)
	var rack_height: float = $Rack/RackTexture.global_position.y
	if rack_tiles.size() == 0:
		return
	# TODO: Andy will fix this bad code
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var drag_area: Vector2 = drag_region.global_position
	if (mouse_pos.y > drag_area.y && grabbed_tile != null && hover_index != -1):
		var space_per_tile: float = rack_size.x / count
		var left_space: float = space_per_tile / 2 - 75
		var rack_index: int = 0
		for n: int in range(count):
			if hover_index != n:
				tween.parallel().tween_property(rack_tiles[rack_index], 
						"position", 
						Vector2(left_space + space_per_tile * n, rack_height), 
						0.2)
				tween.parallel().tween_property(rack_tiles[rack_index], 
						"scale", Vector2(tile_scale, tile_scale), 0.2)
				rack_index += 1
	else:
		var space_per_tile: float = $Rack.size.x / rack_tiles.size()
		var left_space: float = space_per_tile / 2 - 75
		for n: int in range(rack_tiles.size()):
			tween.parallel().tween_property(rack_tiles[n], 
					"global_position", 
					Vector2(left_space + space_per_tile * n, rack_height), 
					0.2)
			tween.parallel().tween_property(rack_tiles[n], "scale", 
					Vector2(tile_scale, tile_scale), 0.2)


## Input capture when user input occurs
func _input(event: InputEvent):
	if event is InputEventKey && event.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
	if is_bag_open:
		return
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		if (mouse_pos.y > $Rack/DragArea.global_position.y && 
				grabbed_tile != null && hover_space == null):
			var space_per_tile: float = $Rack.size.x / (rack_tiles.size() + 1)
			var new_hover_index: int = floori(
					mouse_pos.x / space_per_tile)
			if new_hover_index != hover_index:
				hover_index = new_hover_index
				anim_render_rack()
		elif hover_index != -1 && mouse_pos.y <= $Rack/DragArea.global_position.y:
			hover_index = -1
			anim_render_rack()
	elif event is InputEventMouseButton:
		if grabbed_tile != null && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			drop_grabbed_tile()


## This function is called when the player opens their bag to view the menu
func on_bag_opened():
	$BagMenu.visible = true
	$BagMenu.render_tiles()
	for n in range(rack_tiles.size()):
		rack_tiles[n].visible = false
	$Rack.visible = false
	is_bag_open = true


## This function is called when the player closes the bag to view the board
func on_bag_closed():
	$BagMenu.visible = false
	for n in range(rack_tiles.size()):
		rack_tiles[n].visible = true
	$Rack.visible = true
	is_bag_open = false
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var new_alpha: Color = $Bag/BagSprite.self_modulate
	new_alpha.a = 1
	tween.parallel().tween_property($Bag/BagSprite, "self_modulate", new_alpha, 0.2)
	tween.parallel().tween_property($Bag/BagSprite, "position", Vector2(75, 75), 0.2)
	tween.parallel().tween_property($Bag/BagSprite, "scale", Vector2(1, 1), 0.2)
