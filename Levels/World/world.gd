extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = $Player
onready var crosshair = $Crosshair
onready var enemy = $Enemy
onready var map1 = $Map1
onready var map2 = $Map2
# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair.connect("send_position", player, "_update_mouse_pos")
	enemy.connect("spawn_eyes", map1, "_init_spawn_eyes")
	enemy.connect("spawn_eyes", map2, "_init_spawn_eyes")
	map1.connect("eyes_spawned", map2, "_update_spawn_eyes")
	map2.connect("eyes_spawned", map1, "_update_spawn_eyes")
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):



