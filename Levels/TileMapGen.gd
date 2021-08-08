extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var speed = 100
export (int) var upper_floor_limit = 10
export (int) var lower_floor_limit = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	create_map(upper_floor_limit, lower_floor_limit, 63, 0, 36)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x = position.x - speed * delta
	update_dirty_quadrants()
	if position.x < -1024:
		reset_map()
	
#	pass


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
	randomize()
	var current_x = 0
	var current_y = 36
	while length - current_x - floor_low_lim >= floor_low_lim:
		var insert_wall = randi() % 2
		var x = int(rand_range(current_x + 2, current_x + 10))
		var y = int(rand_range(current_y + 15 , current_y - 15))
		if y > 36:
			y -= 20
		elif y < 10:
			y += 20
		var platform_len = int(rand_range(floor_low_lim, floor_up_lim))
		if (length - x) - platform_len  > 1:
			var xandy = create_platform(x,y,platform_len)
			if insert_wall == 1:
				var wall_distance = randi() % 15
				var wall_length = int(rand_range(5, 10))
				if wall_distance + xandy[0] < 63:
					xandy = create_wall(xandy[0] + wall_distance, xandy[1], wall_length)
			current_x += xandy[0]
			current_y = xandy[1]
#		else: 
#			return create_map(floor_up_lim, floor_low_lim, length, current_x, current_y)

func reset_map():
	position.x += 2048
	clear()
	create_map(upper_floor_limit, lower_floor_limit, 63, 0 , 36)

func create_wall(x,y,length):
	for i in range(length):
		set_cell(x,y-i, 1)
	return [x, y - length]
