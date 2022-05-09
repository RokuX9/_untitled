extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int) var health = 10
export (int) var force = 5
onready var sprite = $AnimatedSprite
onready var hit_timer = $hit_timer
onready var hit_area = $Hit_Area
var velocity = Vector2.ZERO
var stunned = false
var gravity = 100
var move_speed = 100
var direction = 1
var dead = false

signal die(name)

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_timer.connect("timeout", self, "_on_hit_timeout")
	hit_area.connect("body_entered", self, 'on_body_enter_hit')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	horizontal_movement(delta)
	if !dead:
		if !stunned:
			vertical_movement()
	else:
		velocity.y = gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	if health <= 0 :
		die()
	

func _on_hit_timeout():
	stunned = false

func vertical_movement():
	sprite.play('fly')
	if position.y <= 0:
		direction = 1
	if position.y >= 600:
		direction = -1
	velocity.y = direction *  move_speed * 2
		

#func horizontal_movement(delta):
#	position.x -= move_speed * delta

func get_hit(_force):
	if !dead:
		health -= _force
		stunned = true
		velocity.y = 0
		sprite.play('hit')
		sprite.frame = 0
		hit_timer.start(1)

func die():
	dead = true
	sprite.play('death')
	emit_signal('die', 'flying_eye')

func on_body_enter_hit(body):
	#print_debug('eye_detect')
	if body.has_method('_get_hit'):
		var _direction = 0
		if position.x - body.position.x < 0:
			_direction = 1
		elif position.x - body.position.x > 0:
			_direction = -1
		if !body.attacking:
			body._get_hit(force, direction)
	else:
		direction = 1
