class_name MainEnvironment extends Node2D
var base_tile_scene: PackedScene = load("res://base_tile.tscn")

var grabbed_tile: BaseTile
var rack_tiles: Array = []
var hover_index: int = -1
var temp = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	# Addition of random cells for testing
	for n in range(12):
		rack_tiles.push_back(_temp_generate_random_tile())
		add_child(rack_tiles[n])
	render_tiles()
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Possible idea for how to handle animations: Have a dict that stores a reference
	# to whatever variable is being animated, the starting and final values, the
	# total time for animation, and time elapsed. Then do math to update values
	# in process. This is assuming that Godot doesn't have any built-in ways to do
	# this
	# Animation for Tile Dragging
	if grabbed_tile != null:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var center_pos: Vector2 = grabbed_tile.position
		center_pos.x += 75
		center_pos.y += 10
		var velocity: float = center_pos.distance_to(mouse_pos)*10
		var angle: float = mouse_pos.angle_to_point(center_pos)
		var x_diff: float = -cos(angle)*velocity*delta
		var y_diff: float = -sin(angle)*velocity*delta
		if abs(grabbed_tile.position.x - mouse_pos.x) < x_diff:
			grabbed_tile.position.x = mouse_pos.x-75
			grabbed_tile.rotation = 0
		else:
			grabbed_tile.position.x += x_diff
			grabbed_tile.rotation = -atan(cos(angle)*velocity*delta/10)/(PI/4)
		if abs(grabbed_tile.position.y - mouse_pos.y) < y_diff:
			grabbed_tile.position.y = mouse_pos.y-10
		else:
			grabbed_tile.position.y += y_diff

# Render rack tiles. Will need to eventually be overhauled to make it animated
func render_tiles():
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var count = rack_tiles.size()+1 if grabbed_tile != null else rack_tiles.size()
	var scale: float = 1
	if count > 12:
		scale = 12.0/(ceil(count/4.0)*4.0)
		tween.tween_property(get_node("Rack/RackTexture"), "scale", Vector2(scale,scale), 0.2)
		tween.tween_property(get_node("Rack/RackTexture"), "position.y", 1080-200*scale, 0.2)
		tween.tween_property(get_node("Rack/RackTexture"), "size.x", 1920*(1/scale), 0.2)
	else:
		if rack_tiles.size() == 0:
			return
		if get_viewport().get_mouse_position().y > 780 && grabbed_tile != null && hover_index != -1:
			var space_per_tile: float = 1920/count
			var left_space: float = (space_per_tile)/2-75
			var rack_index: int = 0
			for n in range(count):
				if hover_index != n:
					tween.parallel().tween_property(rack_tiles[rack_index], "position", Vector2(left_space+space_per_tile*n,875), 0.2)
					rack_index += 1
		else:
			var space_per_tile: float = 1920/rack_tiles.size()
			var left_space: float = (space_per_tile)/2-75
			for n in range(rack_tiles.size()):
				tween.parallel().tween_property(rack_tiles[n], "position", Vector2(left_space+space_per_tile*n,875), 0.2)
		
var possible_chars = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
var rng = RandomNumberGenerator.new()
func _temp_generate_random_tile():
	var base_tile = base_tile_scene.instantiate()
	base_tile.default_init(possible_chars[rng.randi_range(0,25)])
	return base_tile

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT && event.pressed:
			for tile: BaseTile in rack_tiles:
				if tile.get_rect().has_point(event.position):
					grabbed_tile = tile
					rack_tiles.erase(tile)
					render_tiles()
					break
		elif event.button_index == MouseButton.MOUSE_BUTTON_LEFT && \
			!event.pressed && grabbed_tile != null:
			if hover_index == -1:
				rack_tiles.push_back(grabbed_tile)
			else:
				rack_tiles.insert(hover_index, grabbed_tile)
			grabbed_tile.rotation = 0
			grabbed_tile = null
			render_tiles()
	elif event is InputEventMouseMotion:
		if get_viewport().get_mouse_position().y > 780 && grabbed_tile != null:
			var space_per_tile = 1920/(rack_tiles.size()+1)
			var new_hover_index = floori(get_viewport().get_mouse_position().x/space_per_tile)
			if temp:
				var RAWR
			if new_hover_index != hover_index:
				hover_index = new_hover_index
				render_tiles()
		elif get_viewport().get_mouse_position().y <= 780 && hover_index != -1:
			temp = true
			hover_index = -1
			render_tiles()
