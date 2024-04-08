class_name MainEnvironment extends Node2D
var base_tile_scene: PackedScene = load("res://base_tile.tscn")

var grabbed_tile
var rack_tiles = []
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
		center_pos.y -= 75
		var velocity: float = center_pos.distance_to(mouse_pos)*10
		var angle: float = mouse_pos.angle_to_point(center_pos)
		if velocity < 10:
			grabbed_tile.position.x = mouse_pos.x
			grabbed_tile.position.y = mouse_pos.y+75
			grabbed_tile.rotation = 0
		else:
			grabbed_tile.position.x -= cos(angle)*velocity*delta
			grabbed_tile.position.y -= sin(angle)*velocity*delta
			grabbed_tile.rotation = -atan(cos(angle)*velocity*delta/10)/(PI/4)

# Render rack tiles. Will need to eventually be overhauled to make it animated
func render_tiles():
	var count = rack_tiles.size()+1 if grabbed_tile != null else rack_tiles.size()
	var scale: float = 1
	if count > 12:
		scale = 12.0/(ceil(count/4.0)*4.0)
		get_node("Rack/RackTexture").scale = Vector2(scale,scale)
		get_node("Rack/RackTexture").position.y = 1080-200*scale
		get_node("Rack/RackTexture").size.x = 1920*(1/scale)
	else:
		if grabbed_tile != null:
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		else:
			var space_per_tile = 1920/count
			var left_space = (space_per_tile)/2
			for n in range(rack_tiles.size()):
				rack_tiles[n].position = Vector2(left_space+space_per_tile*n,950)
		
var possible_chars = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
var rng = RandomNumberGenerator.new()
func _temp_generate_random_tile():
	var base_tile = base_tile_scene.instantiate()
	base_tile.default_init(possible_chars[rng.randi_range(0,25)])
	return base_tile
