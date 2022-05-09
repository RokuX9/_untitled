extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(tilemap.get_collision_layer_bit(2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
