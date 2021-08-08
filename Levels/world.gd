extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = $Player
onready var crosshair = $Crosshair
# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair.connect("send_position", player, "_update_mouse_pos")
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):



