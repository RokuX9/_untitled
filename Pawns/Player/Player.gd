extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var crosshair_pos = Vector2.ZERO
var dash_pos = Vector2.ZERO
var dashing = false
var sliding = false
var attacking = false
var attackFinished = true
var attack_counter = 0
export (int) var move_speed = 100
export (int) var accl = 20
export (int) var friction = 50
export (int) var gravity = 50
export (int) var jumpforce = 1500
export (int) var max_fall_speed = 500
export (int) var jump_amount = 5
export (int) var wall_accl = 10
export (int) var wall_slide_speed = 200
export (int) var hit_force = 5
export (int) var health = 30
var stunned = false
var dead = false
var used_jumps = 0
var grounded = false
var invurnable = false
var stage1_done = false

var number_of_goblins = 10
var number_of_flying_eyes = 5
var goblin_kills = 0
var flying_eye_kills = 0

var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO

signal finished_mobs

onready var PlayerAnimatedSprite = $AnimatedSprite
onready var timer = $Timer
onready var attack_timer = $Attack_Timer
onready var raycast = $RayCast2D
onready var inv_timer = $Inv_Timer
onready var camera = $Camera2D
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "_on_timer_runout")
	attack_timer.connect("timeout", self, "_on_attack_timeout")
	PlayerAnimatedSprite.connect("animation_finished", self, "_on_attack_end")
	inv_timer.connect("timeout", self, 'on_inv_timeout')
	timer.stop()
#	var PlayerAnimatedSprite = $AnimatedSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var snap = Vector2.DOWN * 16 if is_on_floor() else Vector2.ZERO
	if !dead:	
		input_vector = get_input()
		grounded = is_on_floor()
		
		flip_sprite_and_raycast()
		if !dashing and !stunned:
			horizontal_velocity(delta)
			vertical_velocity()
			attack()
		sliding = wall_slide()	
		
		if Input.is_action_just_pressed("skill"):
			PlayerAnimatedSprite.play('air-attack1')
			velocity = dash(1500)
			snap = Vector2.ZERO
		if health <= 0:
			die()
			
		if dashing:
			hit(hit_force * 2)
			raycast.cast_to = dash_pos * 16
			
		if goblin_kills >= 1 and flying_eye_kills >= 1:
			print_debug('we done')
	else:
		if Input.is_action_just_pressed("reset"):
			get_tree().reload_current_scene()
		
		
	velocity = move_and_slide_with_snap(velocity, snap, Vector2(0,-1))
	camera.global_position.y = 300
	

func get_input():
	var _input_vector = Vector2.ZERO
	_input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	_input_vector = _input_vector.normalized()
	return _input_vector
	
	
func dash(dash_speed):
	dashing = true
	var dash_angle = position.direction_to(crosshair_pos)
	dash_pos = dash_angle
	velocity = Vector2(dash_angle.x * dash_speed, dash_angle.y * dash_speed)
	print_debug(dash_angle)
	
	timer.start(0.2)
	return velocity
	
func _on_timer_runout():
	velocity.x = move_speed * dash_pos.x
	velocity.y = max_fall_speed * dash_pos.y
	dashing = false
	
func _update_mouse_pos(pos):
	crosshair_pos = pos

func horizontal_velocity(delta):
	if input_vector.x != 0:
		velocity = velocity.move_toward(input_vector * move_speed, accl * delta)
		if grounded and !sliding and !attacking:
			PlayerAnimatedSprite.play("run2")
			#print_debug('run')

	elif input_vector.x == 0 and !dashing:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if grounded and !attacking and !stunned:
			PlayerAnimatedSprite.play('idle-2')
			#print_debug('idle')
			
func vertical_velocity():
	velocity.y += gravity
	if Input.is_action_just_pressed("ui_up") and used_jumps < jump_amount:
		
		if is_on_wall() and input_vector.x != 0 and not grounded:
			velocity.x = -move_speed * input_vector.x
			
		velocity.y = -jumpforce
		used_jumps += 1
		
	if !grounded and input_vector.y >= 0 and velocity.y < 0 :
		velocity.y = velocity.y * 0.5
		
	if velocity.y < 0 and !attacking:
		PlayerAnimatedSprite.play('jump')
		#print_debug('jump')
		
	if velocity.y > 0 and !grounded and !sliding and !attacking:
		PlayerAnimatedSprite.play('fall')
		#print_debug('fall')
	if velocity.y > max_fall_speed and !dashing:
		velocity.y = max_fall_speed
		
	if grounded:
		used_jumps = 0
		
	if position.y == 0:
		velocity.y = 0

func wall_slide():
	if is_on_wall() and input_vector.x != 0 and not is_on_floor():
		reset_attack()
		timer.stop()
		dashing = false
		used_jumps = 0
		PlayerAnimatedSprite.play("wall-slide")
		#print_debug('slide')
		if input_vector == Vector2.LEFT:
			PlayerAnimatedSprite.flip_h = true
			velocity.x = -100
		elif input_vector == Vector2.RIGHT:
			velocity.x = 100
			PlayerAnimatedSprite.flip_h = false
		#if velocity.y < 0:
		#	velocity.y = velocity.y * 0.3
		if velocity.y > 0:
			velocity.y = min(velocity.y + wall_accl, wall_slide_speed)
		return true
	else:
		return false

func flip_sprite_and_raycast():
	if !sliding:
		if input_vector.x < 0:
			PlayerAnimatedSprite.flip_h = true
			raycast.cast_to = Vector2(-16,0)
		elif input_vector.x > 0:
			PlayerAnimatedSprite.flip_h = false
			raycast.cast_to = Vector2(16,0)

func attack():
	if Input.is_action_just_pressed("attack") && attackFinished:
		if grounded:
			if attack_counter == 0:
				attack_counter += 1
				PlayerAnimatedSprite.play('attack1')
			elif attack_counter == 1:
				attack_counter += 1
				PlayerAnimatedSprite.play('attack2')
			elif attack_counter == 2:
				PlayerAnimatedSprite.play('attack3')
				attack_counter = 0
		else:
			if attack_counter == 0:
				attack_counter += 1
				PlayerAnimatedSprite.play('air-attack1')
			elif attack_counter == 1:
				PlayerAnimatedSprite.play('air-attack2')
				attack_counter = 0
		hit(hit_force)
		attack_timer.start(1)
		attacking = true
		attackFinished = false

func hit(force):
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target:
			if target.has_method('get_hit'):
				if target.health > 0:
					if target.health - force <= 0:
						if target.name == 'Goblin':
							goblin_kills += 1
						if target.name == 'Flying_Eye':
							flying_eye_kills += 1
					target.get_hit(force)

func _on_attack_timeout():
	attacking = false
	attack_counter = 0

func reset_attack():
	attackFinished = true
	attacking = false

func _on_attack_end():
	if PlayerAnimatedSprite.animation.find("attack") >= 0:
		reset_attack()

func _get_hit(force, direction):
	if !invurnable:
		reset_attack()
		health -= force
		stunned = true
		velocity.x = direction * move_speed / 2
		PlayerAnimatedSprite.play('hurt')
		yield(PlayerAnimatedSprite, "animation_finished")
		invurnable = true
		inv_timer.start(2)
		stunned = false
		print_debug('im hit!')

func die():
	dead = true
	PlayerAnimatedSprite.play('die')
	yield(PlayerAnimatedSprite, "animation_finished")
	velocity = Vector2.ZERO

func on_inv_timeout():
	invurnable = false

func add_kill(name):
	if name == 'goblin':
		goblin_kills += 1
	elif name == 'flying_eye':
		flying_eye_kills +=1
