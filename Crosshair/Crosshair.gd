extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal send_position(pos)


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	position= Vector2(612, 300) # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		position += move_and_clamp_to_screen(event.get_relative()) * 2
		emit_signal("send_position", position)

func move_and_clamp_to_screen(direction):
	var result = Vector2.ZERO
	if position.x < 1024 and position.x > 0:
		result.x = direction.x
	else:
		if position.x >= 1024 and direction.x < 0:
			result.x = direction.x
		elif position.x <= 0 and direction.x > 0:
			result.x = direction.x
	if position.y < 600 and position.y > 0:
		result.y = direction.y
	else:
		if position.y <= 600 and direction.y > 0:
			result.y = direction.y
		elif position.y >= 0 and direction.y < 0:
			result.y = direction.y
	return result
