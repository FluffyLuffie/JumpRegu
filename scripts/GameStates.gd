extends Node

var starting_level_x: int = 1
var starting_level_y: int = 0
var starting_pos: Vector2 = Vector2(0, 121)

var directory = Directory.new()

var game_vp: Viewport
var player: KinematicBody2D

var gravity:float = 700
var level_height:float = 360.0
var level_width:float = 640.0

var level_x:int
var level_y:int
var current_level

var cutscene: bool = false
var chicken_cooked: bool = false

var paused: bool = false
var timer_active: bool = false
var timer: float = 0.0

func _ready():	
	game_vp = get_node("/root/GameWorld/ViewportContainer/Viewport")
	
	spawn_player(starting_pos)
	
	# warning-ignore:return_value_discarded
	load_level(starting_level_x, starting_level_y)
	current_level.add_child(load("res://scenes/Title.tscn").instance())

func load_level(delta_x:int, delta_y:int) -> bool:
	var next_level_x:int = level_x + delta_x
	var next_level_y:int = level_y + delta_y
	var next_level_path = "res://scenes/levels/" + str(next_level_x) + "_" + str(next_level_y) + ".tscn"
	
	if directory.file_exists(next_level_path):
		if current_level:
			game_vp.remove_child(current_level)
			current_level.queue_free()
		
		level_x = next_level_x
		level_y = next_level_y
		current_level = load(next_level_path).instance()
		game_vp.add_child(current_level)
		game_vp.move_child(current_level, 1)
		return true
	return false

func spawn_player(pos: Vector2) -> void:
	player = load("res://scenes/Regu.tscn").instance()
	player.position = pos
	game_vp.add_child(player)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("jump"):
		timer_active = true
	
	if timer_active && !paused:
		timer += delta
