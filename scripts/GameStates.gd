extends Node

var starting_level_x: int = 1
var starting_level_y: int = 0

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
		
		# add plants
		var rand: RandomNumberGenerator = RandomNumberGenerator.new()
		rand.seed = next_level_x * 88 + next_level_y * 1144
		var plants: TileMap = load("res://scenes/Plants.tscn").instance()
		current_level.add_child(plants)
		var level_tiles: TileMap = current_level.get_node("TileMap")
		for y in range(-11, 11):
			for x in range(-20, 20):
				# if above a valid tile is empty
				if level_tiles.get_cell(x, y) == -1 and level_tiles.get_cell(x, y + 1) == 0:
					# chance for plant
					if rand.randi_range(0, 9) > 1:
						plants.set_cell(x, y, rand.randi_range(0, 7), bool(rand.randi_range(0, 1)))
		
		game_vp.add_child(current_level)
		game_vp.move_child(current_level, 1)
		
		return true
	return false

func spawn_player(pos: Vector2 = Vector2(0, 121)) -> void:
	player = load("res://scenes/Regu.tscn").instance()
	player.position = pos
	game_vp.add_child(player)
	
func _physics_process(delta: float) -> void:
	if timer_active && !paused:
		timer += delta
