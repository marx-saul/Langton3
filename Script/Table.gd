extends Node

const cons = preload("res://Script/cons.gd")
const Cell = preload("res://Scene/ACell.tscn")
const Ant  = preload("res://Scene/Ant.tscn")

signal generation_proceeded

var cell_num_x:int
var cell_num_y:int
var cell_size_x:int
var cell_size_y:int

var cells:Array
var ants:Array

var current_ant_num:int = 0
var simulating:bool = true
var sim_speed:float = 10

func init(cnx:int, cny:int, csx:int, csy:int):
	cell_num_x = cnx
	cell_num_y = cny
	cell_size_x = csx
	cell_size_y = csy
	cells = []
	
	# create the table
	for x in range(cell_num_x):
		var row = []
		for y in range(cell_num_y):
			var cell = Cell.instance()
			cell.init(0, csx, csy)
			cell.position = Vector2(x * csx, y * csy)
			row.append(cell)
			add_child(cell)
		cells.append(row)
	
	ants = []

func clear():
	simulating = false
	for i in range(cell_num_x):
		for j in range(cell_num_y):
			cells[i][j].change_state(0)
	clear_ants()
	
func clear_ants():
	for ant in ants:
		remove_child(ant)
		ant.queue_free()
	ants = []

func add_ant(dir:int, x:int, y:int, state_map:Array, dir_map:Array):
	var ant = Ant.instance()
	ant.init(dir, cell_size_x/2, cell_size_y/2, state_map, dir_map)
	add_child(ant)
	put_ant(ant, x, y)
	ants.append(ant)

func put_ant(ant, x:int, y:int):
	ant.x = x
	ant.y = y
	draw_ant(ant)

func draw_ant(ant):
	ant.position = Vector2(ant.x*cell_size_x + cell_size_x/2, ant.y*cell_size_y + cell_size_y/2)

func one_step(ant):
	# change the table
	var cell = cells[ant.x][ant.y]
	cell.change_state(ant.state_map[cell.state])
	ant.change_dir((ant.dir + ant.dir_map[cell.state]) % cons.ORTHOGONAL_DIRS)
	
	# move the ant
	var dir_diff_x: int
	var dir_diff_y: int
	match ant.dir:
		0:
			dir_diff_x = 0
			dir_diff_y = 1
		1:
			dir_diff_x = 1
			dir_diff_y = 1
		2:
			dir_diff_x = 1
			dir_diff_y = 0
		3:
			dir_diff_x = 1
			dir_diff_y = -1
		4:
			dir_diff_x = 0
			dir_diff_y = -1
		5:
			dir_diff_x = -1
			dir_diff_y = -1
		6:
			dir_diff_x = -1
			dir_diff_y = 0
		7:
			dir_diff_x = -1
			dir_diff_y = 1
		
	var newx = (ant.x + dir_diff_x) % cell_num_x
	if newx < 0: newx += cell_num_x
	var newy = (ant.y + dir_diff_y) % cell_num_y
	if newy < 0: newy += cell_num_y
	put_ant(ant, newx, newy)

func simulate():
	simulating = true
	while simulating:
		one_step(ants[current_ant_num])
		emit_signal("generation_proceeded")
		current_ant_num += 1
		current_ant_num %= ants.size()
		yield(get_tree().create_timer(1.0 / sim_speed), "timeout")

###########################################################

func test_ant():
	# Langton's original ant
	"""add_ant(
		0, cell_num_x/4, cell_num_y/4,
		[1, 0, 3, 2, 5, 4, 7, 6],
		[2, 6, 2, 6, 2, 6, 2, 6]
	)"""
	# colorful version
	add_ant(
		0, 32, 32,
		[1, 2, 3, 4, 5, 6, 7, 0],
		[2, 6, 2, 6, 2, 6, 2, 6]
	)
	"""add_ant(
		0, cell_num_x/2, cell_num_y/2,
		[1, 2, 3, 4, 5, 6, 7, 0],
		[2, 6, 2, 6, 6, 2, 2, 6]
	)"""

func _ready():
	pass
