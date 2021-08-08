extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = 50
onready var spriteanimation = $AnimatedSprite
onready var timer = $Timer
onready var hit_timer = $Hit_Timer
var velocity = Vector2.ZERO
var move_speed = 100
var flipped = -1
var waiting = false
export (int) var health = 30
var dead = false
var stunned = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, '_on_timeout')
	hit_timer.connect("timeout", self, '_on_hit_timeout')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravity
	if !dead and !stunned:
		if velocity.x < 0:
			spriteanimation.flip_h = true
		else:
			spriteanimation.flip_h = false
		if !waiting:
			if !is_on_edge():
				velocity.x = move_speed * flipped
				spriteanimation.play('run')
			else:
				spriteanimation.play('idle')
				velocity.x = 0
				waiting = true
				timer.start(0.5)
	if health <= 0 and !dead:
		die()
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	if position.x < -50:
		queue_free()
	
func is_on_edge():
	if test_move(Transform2D(0.0 ,Vector2(position.x + (16 * flipped), position.y)), Vector2.DOWN * 8):
		return false
	else:
		return true

func _on_timeout():
	flipped = flipped * -1
	waiting = false
	print_debug('flipped')
	
func get_hit(force):
	if !dead:
		health -= force
		stunned = true
		velocity.x = 0
		spriteanimation.play('take_hit')
		spriteanimation.frame = 0
		hit_timer.start(1)
	
func die():
	dead = true
	velocity.x = 0
	spriteanimation.play('death')

func _on_hit_timeout():
	stunned = false
