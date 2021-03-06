extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var speed = 100
export (int) var upper_floor_limit = 18
export (int) var lower_floor_limit = 7
var spawn_eyes = false
var flying_eye = preload('res://Pawns/Flying_Eye/Flying_Eye.tscn')
var goblin = preload("res://Pawns/Goblin/Goblin.tscn")

signal eyes_spawned
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	create_map(upper_floor_limit, lower_floor_limit, 63, 0, 36)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func create_platform(x, y, length):
	for i in range(length):
		if i == 0:
			set_cell(x+i, y, 0)
		else:
			
			if i == length - 1:
				set_cell(x+i, y, 2)
			else:
				set_cell(x+i, y, 1)
	return [x + length ,y]

func create_map(floor_up_lim, floor_low_lim, length, _current_x, _current_y):
	var current_x = 0
	var current_y = 36
	var last_eye_x_pos = 0
	while length - current_x - floor_low_lim >= floor_low_lim:
		var insert_wall = randi() % 2
		var spawn_eye = randi() % 2
		var spawn_goblin = randi() % 2
		var x = int(rand_range(current_x + 2, current_x + 10))
		var y = int(rand_range(current_y + 15 , current_y - 15))
		if y > 36:
			y -= 20
		elif y < 10:
			y += 20
		var platform_len = int(rand_range(floor_low_lim, floor_up_lim))
		if (length - x) - platform_len  > 1:
			var xandy = create_platform(x,y,platform_len)
			if spawn_goblin == 1:
				create_goblin((xandy[0] - 3) * 16, (xandy[1] - 2) * 16) 
				
			if insert_wall == 1:
				var wall_distance = randi() % 15
				var wall_length = int(rand_range(5, 10))
				if wall_distance + xandy[0] < 63:
					xandy = create_wall(xandy[0] + wall_distance, xandy[1], wall_length)
			if spawn_eye:
				var intented_x_pos = current_x + 2 if insert_wall == 1 else current_x + 1
				if intented_x_pos > last_eye_x_pos:
					var eye_position = intented_x_pos * 16
					create_eye(eye_position)
					last_eye_x_pos = intented_x_pos
			current_x += xandy[0]
			current_y = xandy[1]
		
	last_eye_x_pos = 0

func reset_map():
	position.x += 2048
	clear()
	create_map(upper_floor_limit, lower_floor_limit, 63, 0 , 36)

func create_wall(x,y,length):
	for i in range(length):
		set_cell(x,y-i, 1)
	return [x, y - length]

func create_eye(position_x):
	var eye_instance = flying_eye.instance()
	var height = int(rand_range(0, 600))
	eye_instance.position.x = position_x
	eye_instance.position.y = height
	add_child(eye_instance)

func create_goblin(position_x, position_y):
	var goblin_instance = goblin.instance()
	goblin_instance.position.x = position_x
	goblin_instance.position.y = position_y
	add_child(goblin_instance)

func _init_spawn_eyes():
	spawn_eyes = true
	print_debug('spawn_eyes set!')

func _update_spawn_eyes():
	spawn_eyes = false
	print_debug('spawn_eyes updated!')
