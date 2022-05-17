extends Node

var directory = Directory.new()

var game_vp

var gravity:float = 700
var level_height:float = 360.0
var level_width:float = 640.0

var level_x:int = 0
var level_y:int = 0
var current_level

#move somewhere else?
func _ready():	
	game_vp = get_node("/root/GameWorld/ViewportContainer/Viewport")
	current_level = get_node("/root/GameWorld/ViewportContainer/Viewport/Level0_0")

func load_level(delta_x:int, delta_y:int):
	var next_level_x:int = level_x + delta_x
	var next_level_y:int = level_y + delta_y
	var next_level_path = "res://scenes/levels/Level" + str(next_level_x) + "_" + str(next_level_y) + ".tscn"
	
	if directory.file_exists(next_level_path):
		current_level.queue_free()
		
		level_x = next_level_x
		level_y = next_level_y
		current_level = load(next_level_path).instance()
		game_vp.add_child(current_level)
		game_vp.move_child(current_level, 1)
