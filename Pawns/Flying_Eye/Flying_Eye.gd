extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int) var health = 10
onready var sprite = $AnimatedSprite
onready var hit_timer = $hit_timer
var velocity = Vector2.ZERO
var stunned = false
var gravity = 50
var move_speed = 100
var direction = 1
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_timer.connect("timeout", self, "_on_hit_timeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	horizontal_movement(delta)
	if !dead:
		if !stunned:
			vertical_movement()
	else:
		velocity.y = gravity
	move_and_slide(velocity, Vector2.UP)
	if position.x < -50:
		queue_free()
	if health <= 0 :
		die()
	

func _on_hit_timeout():
	stunned = false

func vertical_movement():
	if position.y <= 0:
		direction = 1
	if position.y >= 600:
		direction = -1
	velocity.y = direction *  move_speed * 4
		

#func horizontal_movement(delta):
#	position.x -= move_speed * delta

func get_hit(force):
	if !dead:
		health -= force
		stunned = true
		velocity.x = 0
		sprite.play('hit')
		sprite.frame = 0
		hit_timer.start(1)

func die():
	dead = true
	velocity.x = 0
	sprite.play('death')
