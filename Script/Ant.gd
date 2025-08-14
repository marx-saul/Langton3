extends Node

const cons = preload("res://Script/cons.gd")
var dir:int
var color: Color
var x: int
var y: int
var state_map: Array
var dir_map: Array

func init(_dir: int, _size_x: int, _size_y: int, _state_map: Array, _dir_map: Array):
	$Polygon2D.set_polygon([Vector2(0, _size_y), Vector2(_size_x, 0), Vector2(0, -_size_y), Vector2(-_size_x, 0)])
	$Polygon2D.color = cons.LANG_ANT_COLOR
	change_dir(_dir)
	self.state_map = _state_map
	self.dir_map = _dir_map
	
	for d in dir_map:
		assert(d >= 0)

func change_dir(_dir: int):
	self.dir = _dir

func _ready():
	pass
