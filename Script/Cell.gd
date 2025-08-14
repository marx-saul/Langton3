extends Node

const cons = preload("res://Script/cons.gd")
var state: int
var size_x: int
var size_y: int

func init(_state: int, _size_x: int, _size_y: int):
	$Polygon2D.set_polygon([Vector2(0, 0), Vector2(_size_x, 0), Vector2(_size_x, _size_y), Vector2(0, _size_y)])
	change_state(_state)

func change_state(_state: int):
	self.state = _state
	$Polygon2D.color = cons.LANG_COLORS[_state]

func _ready():
	pass
