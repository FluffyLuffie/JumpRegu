extends KinematicBody2D

var terminal_velocity:float = 450.0

var is_active: bool = false
var velocity: Vector2

var chicken_maybe = preload("res://scenes/ChickenMaybe.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
	velocity.y += GameStates.gravity * delta
	velocity.y = min(velocity.y, terminal_velocity)
	rotate(-15.0 * delta)
	
	if is_on_floor():
		explode()
	
	if position.y > GameStates.level_height / 2.0:
		if GameStates.load_level(0, -1):
			position.y -= GameStates.level_height
			if GameStates.level_y == 0:
				collision_layer = 2
				collision_mask = 1
	
func launch() -> void:
	is_active = true
	velocity = Vector2(18.4, -400.0)
	$AudioStreamPlayer.play()
	get_parent().remove_child(self)
	GameStates.game_vp.add_child(self)
	GameStates.player = self
	
func explode() -> void:
	var explosion: Node2D = load("res://scenes/Explosion.tscn").instance()
	explosion.position = position
	explosion.get_node('Particles2D').emitting = true
	GameStates.current_level.add_child(explosion)
	
	if !GameStates.cutscene:
		GameStates.spawn_player(position)
		spawn_chicken(1)
	else:
		spawn_chicken(3)
		var credits: Node2D = load("res://scenes/Credits.tscn").instance()
		credits.get_node("Time").text = "Time: " + str(GameStates.timer)
		var game_world: Node2D = get_node("/root/GameWorld")
		game_world.add_child(credits)
		game_world.move_child(credits, game_world.get_child_count() - 2)
	
	queue_free()

func spawn_chicken(num: int):
	var rand: RandomNumberGenerator = RandomNumberGenerator.new()
	rand.randomize()
	
	# warning-ignore:unused_variable
	for i in range(num):
		var cm: RigidBody2D = chicken_maybe.instance()
		cm.global_position = position + Vector2(i * 2, -10.0)
		cm.apply_central_impulse(Vector2(rand.randf_range(-300, 300), rand.randf_range(-400, -200)))
		cm.add_torque(rand.randf_range(-150, 150))
		cm.get_node("Sprite").region_rect.position = Vector2(i * 16, 0)
		GameStates.current_level.add_child(cm)
	
