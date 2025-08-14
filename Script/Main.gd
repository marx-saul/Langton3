extends Node

const cons = preload("res://Script/cons.gd")

var generation:int
var is_stopped:bool = false

const cell_num_x:int = 80
const cell_num_y:int = 108
const cell_size_x:int = 8
const cell_size_y:int = 8
var ants_data: Array
var ants_dir: Array
var ants_x: Array
var ants_y: Array

func _on_h_scroll_bar_speed_value_changed(value: float) -> void:
	$Control/LabelSpeed.text="Speed: " + str(int(value))
	$Table.sim_speed = int(value)

func _on_table_generation_proceeded() -> void:
	generation += 1
	$Control/LabelGeneration.text = "Generation: " + str(generation)

func _on_start_stop_button_pressed() -> void:
	is_stopped = not is_stopped
	# stop simulating
	if is_stopped:
		$Control/StartStopButton.text = "Start"
		$Table.simulating = false
	# start simulating
	else:
		$Control/StartStopButton.text = "Stop"
		$Table.simulate()

func _on_reset_button_pressed() -> void:
	$Table.clear()
	generation = 0
	$Control/LabelGeneration.text = "Generation: " + str(generation)
	is_stopped = true
	$Control/StartStopButton.text = "Start"
	refresh_ants()

var color_button_state = 0
func _on_color_button_pressed():
	color_button_state += 1
	color_button_state %= cons.LANG_STATES 
	$Control/ColorButton.text = str(color_button_state)
	$Control/Cell.change_state(color_button_state)

func refresh_ants():
	$Table.clear_ants()
	# set ants
	for i in range(ants_data.size()):
		var state_map = []
		var dir_map = []
		for j in range(cons.LANG_STATES):
			state_map.append(int(ants_data[i][j]))
		for j in range(cons.LANG_STATES, cons.LANG_STATES + cons.ORTHOGONAL_DIRS):
			dir_map.append(int(ants_data[i][j]))
		$Table.add_ant(ants_dir[i], ants_x[i], ants_y[i], state_map, dir_map)

func refresh_ants_edit():
	if $Control/AntsList.selected < 0:
		$Control/AntsEdit.text = ""
		$Control/XEdit.text = ""
		$Control/YEdit.text = ""
	else:
		$Control/AntsEdit.text = ants_data[$Control/AntsList.selected]
		$Control/DirList.select(ants_dir[$Control/AntsList.selected])
		$Control/XEdit.text = str(ants_x[$Control/AntsList.selected])
		$Control/YEdit.text = str(ants_y[$Control/AntsList.selected])

func _on_ants_list_item_selected(index: int) -> void:
	refresh_ants_edit()
	
func _on_delete_button_pressed() -> void:
	if $Control/ntsList.get_selected_id() < 0: return
	ants_data.remove($Control/AntsList.get_selected_id())
	ants_x.remove($Control/AntsList.get_selected_id())
	ants_y.remove($Control/AntsList.get_selected_id())
	$Control/AntsList.remove_item($Control/AntsList.item_count-1)
	refresh_ants_edit()

func _on_add_button_pressed() -> void:
	ants_data.append("0123456701234567")
	ants_dir.append(0)
	ants_x.append(cell_num_x/2)
	ants_y.append(cell_num_y/2)
	$Control/AntsList.add_item("Ant_" + str($Control/AntsList.item_count))
	$Control/AntsList.select($Control/AntsList.item_count-1)
	refresh_ants_edit()

func _on_edit_button_pressed() -> void:
	var text:String = $Control/AntsEdit.text.substr(0, 16)
	var fixed_text:String = ""
	for char_ in text:
		if (char_ == '0' or char_ == '1' or char_ == '2' or char_ == '3' or char_ == '4' or char_ == '5' or char_ == '6' or char_ == '7'):
			fixed_text += char_
	while fixed_text.length() < cons.LANG_STATES + cons.ORTHOGONAL_DIRS:
		fixed_text += '0'
	
	var x = int($Control/XEdit.text) % cell_num_x
	var y = int($Control/YEdit.text) % cell_num_y
	if x < 0: x += cell_num_x
	if y < 0: y += cell_num_y
	ants_data[$Control/AntsList.selected] = fixed_text
	ants_dir[$Control/AntsList.selected] = $Control/DirList.selected
	ants_x[$Control/AntsList.selected] = x
	ants_x[$Control/AntsList.selected] = y
	
	refresh_ants_edit()

func edit_table(x: int, y: int):
	if 0 <= x && x < cell_num_x and 0 <= y && y < cell_num_y:
		$Table.cells[x][y].change_state(color_button_state)

# Bresenham's line algorithm
func edit_table_line():
	var x0 = int(mouse_pos.x/cell_size_x)
	var y0 = int(mouse_pos.y/cell_size_y)
	var x1 = int(get_viewport().get_mouse_position().x / cell_size_x)
	var y1 = int(get_viewport().get_mouse_position().y / cell_size_y)
	var dx = x1 - x0
	var dy = y1 - y0
	var nx = abs(dx)
	var ny = abs(dy)
	var sx = sign(dx)
	var sy = sign(dy)
	
	var x = x0
	var y = y0
	var ix = 0
	var iy = 0
	while ix < nx || iy < ny:
		if (1+ix+ix)*ny < (1+iy+iy)*nx:
			x += sx
			ix += 1
		else:
			y += sy
			iy += 1
		edit_table(x, y)

var mouse_down: bool
var mouse_pos: Vector2
func _input(event):
	if event is InputEventMouseButton:
		mouse_down = event.pressed
		mouse_pos = get_viewport().get_mouse_position()
		if is_stopped:
			edit_table(get_viewport().get_mouse_position().x / cell_size_x, get_viewport().get_mouse_position().y / cell_size_y)
	elif event is InputEventMouseMotion and mouse_down and is_stopped:
		edit_table_line()
		mouse_pos = get_viewport().get_mouse_position()
		

func _ready():
	$Control/Cell.init(0, 40, 40)
	$Control/AntsList.add_item("Ant_0")
	$Control/AntsList.add_item("Ant_1")
	$Control/AntsList.select(0)
	$Control/DirList.add_item("North")
	$Control/DirList.add_item("North East")
	$Control/DirList.add_item("East")
	$Control/DirList.add_item("South East")
	$Control/DirList.add_item("South")
	$Control/DirList.add_item("South West")
	$Control/DirList.add_item("West")
	$Control/DirList.add_item("North West")
	$Control/AntsList.select(0)
	ants_data = ["1234567026262626", "1204537666222262"]
	ants_dir = [0, 2]
	ants_x = [40, 40]
	ants_y = [25, 75]
	$Table.init(cell_num_x, cell_num_y, cell_size_x, cell_size_y)
	refresh_ants()
	$Table.simulate()
	refresh_ants_edit()
	$Control/LabelSpeed.text="Speed: " + str(int($Control/HScrollBarSpeed.value))
	$Table.sim_speed = int($Control/HScrollBarSpeed.value)

