class_name BaseTile extends Node2D

func init_class(char, val):
	$Character.text = char
	$Value.text = val
	
func default_init(char):
	$Character.text = char
	$Value.text = str(get_default_value(char))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var default_vals = {"A":1,"B":3,"C":3,"D":2,"E":1,"F":4, \
					"G":2,"H":4,"I":1,"J":8,"K":5,"L":1, \
					"M":3,"N":1,"O":1,"P":3,"Q":10,"R":1, \
					"S":1,"T":1,"U":1,"V":4,"W":4,"X":8,"Y":4,"Z":10}
func get_default_value(char):
	return default_vals[char]
