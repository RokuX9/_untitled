extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = 50
onready var spriteanimation = $AnimatedSprite
onready var timer = $Timer
onready var hit_timer = $Hit_Timer
onready var fov = $Vision_Area
onready var hit_area = $Hit_Area
onready var raycast = $RayCast2D
var velocity = Vector2.ZERO
var move_speed = 100
var flipped = -1
var waiting = false
export (int) var health = 30
var dead = false
var stunned = false
var target = null
var attacking = false
export (int) var force = 5

signal die(name)

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, '_on_timeout')
	hit_timer.connect("timeout", self, '_on_hit_timeout')
	fov.connect("body_entered", self, '_on_body_enter_sight')
	hit_area.connect("body_entered", self, '_on_body_enter_hit')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravity
	if !dead and !stunned and !attacking:
		if velocity.x < 0:
			spriteanimation.flip_h = true
			raycast.cast_to =Vector2(-30,0)
		elif velocity.x > 0:
			spriteanimation.flip_h = false
			raycast.cast_to = Vector2(30,0)
		if !waiting:
			if !is_on_edge():
				velocity.x = move_speed * flipped
				spriteanimation.play('run')
				if target:
					if fov.overlaps_body(target):
						follow_target(target)
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
	
	
func get_hit(_force):
	if !dead:
		health -= _force
		stunned = true
		velocity.x = 0
		spriteanimation.play('take_hit')
		spriteanimation.frame = 0
		hit_timer.start(1)
	
func die():
	dead = true
	velocity.x = 0
	spriteanimation.play('death')
	emit_signal("die", 'goblin')

func _on_hit_timeout():
	stunned = false

func _on_body_enter_sight(body):
	if body.has_method('_get_hit') and !body.dead and !dead and !stunned:
		target = body
		if position.x - body.position.x < 0 and flipped == -1:
			flipped = flipped * -1
		elif position.x - body.position.x > 0 and flipped == 1:
			flipped = flipped * -1
	elif body.has_method('_get_hit') and body.dead:
		target = null

func follow_target(_target):
	if position.x - _target.position.x < 0 and flipped == -1:
		flipped = flipped * -1
	elif position.x - _target.position.x > 0 and flipped == 1:
		flipped = flipped * -1

func _on_body_enter_hit(body):
	if body.has_method('_get_hit') and !body.dead and !dead and !stunned:
		hit(force)

func hit(_force):
	attacking = true
	velocity.x = 0
	spriteanimation.play('attack')
	spriteanimation.frame = 0
	yield(spriteanimation, "animation_finished")
	if stunned:
		return
	var collider = raycast.get_collider()
	if raycast.is_colliding():
		print_debug('goblin_attack')
		if collider.has_method('_get_hit'):
			var direction = 0
			if position.x - target.position.x < 0:
				direction = 1
			elif position.x - target.position.x > 0:
				direction = -1
			collider._get_hit(_force, direction)
	attacking = false
	if hit_area.overlaps_body(target):
		if position.x - target.position.x < 0 and flipped == -1:
			flipped = 1
			spriteanimation.flip_h = true
			
		elif position.x - target.position.x > 0 and flipped == 1:
			flipped = -1
			spriteanimation.flip_h = false
		hit(_force)
