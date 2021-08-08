extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int) var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= speed * delta
	
	if position.x < -1024:
		queue_free()
#	pass
