extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2.ZERO
var gravity = 50
onready var timer = $Timer
onready var raycast = $RayCast2D
var spawned = false
var goblin = preload('res://Pawns/Goblin/Goblin.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect('timeout', self, 'search_next_platform')
	
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_on_edge() and !raycast.is_colliding():
		velocity.x = 200
		timer.stop()
	elif (is_on_edge() or raycast.is_colliding()) and timer.is_stopped():
		velocity.x = 0
		timer.start(1)
		
	velocity.y += gravity 
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	

func is_on_edge():
	if test_move(Transform2D(0.0 ,Vector2(position.x + 16, position.y)), Vector2.DOWN * 8):
		return false
	else:
		return true

func search_next_platform():
	var found = false
	var step = 32
	var hight = 0
	var width = position.x
	var current_step = 0
	var new_goblin = goblin.instance()
	if !spawned:
		get_parent().add_child(new_goblin)
		spawned = true
	new_goblin.position = position
	
	
	while width + current_step < 1024 and not found:
		current_step += step
		hight = 0
		while hight < 600 and not found:
			if (test_move(Transform2D(0.0 ,Vector2(width + current_step, hight)), Vector2.DOWN)):
				if (test_move(Transform2D(0.0 ,Vector2(width + (current_step + step + 8), hight)), Vector2.DOWN)):
					transform = Transform2D(0.0 ,Vector2(width + current_step + step + 8, hight - 16))
					found = true
					spawned = false
			hight += 16
		
		

func spawn_flying_eyes():
	pass
