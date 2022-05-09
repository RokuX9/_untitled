extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mapGenerator = preload("res://Levels/Generated_Map/Map.tscn")

onready var player = $Player
onready var crosshair = $Crosshair


# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair.connect("send_position", player, "_update_mouse_pos")
	for x in range(1,10):
		var forwardInstance = mapGenerator.instance()
		var backwardInstance = mapGenerator.instance()
		forwardInstance.position.x = 0 + 1024 * x
		backwardInstance.position.x = 0 - 1024 * x
		add_child(forwardInstance)
		add_child(backwardInstance)
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):



