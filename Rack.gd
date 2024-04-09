class_name Rack extends Button

func render_rack_tiles(rack_tiles: Array, grabbed_tile: bool):
	var count = rack_tiles.size()+1 if grabbed_tile else rack_tiles.size()
	var scaleVal: float = 1
	if count > 12:
		scaleVal = 12.0/(ceil(count/4.0)*4.0)
		scale = Vector2(scaleVal,scaleVal)
		$RackTexture.scale = Vector2(scaleVal,scaleVal)
		size.x = 1920*(1/scaleVal)
		$RackTexture.size.x = 1920*(1/scaleVal)
	else:
		if grabbed_tile != null:
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		else:
			var space_per_tile = 1920/count
			var left_space = (space_per_tile)/2
			for n in range(rack_tiles.size()):
				rack_tiles[n].position = Vector2(0,500)
				#rack_tiles[n].position = Vector2(left_space+space_per_tile*n,950)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
