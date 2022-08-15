extends KinematicBody2D

var terminal_velocity:float = 450.0

var is_active: bool = false
var velocity: Vector2

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
	GameStates.game_vp.add_child(explosion)
	
	if !GameStates.cutscene:
		GameStates.spawn_player(position)
	else:
		var credits = load("res://scenes/Credits.tscn").instance()
		credits.get_node("Time").text = "Time: " + str(GameStates.timer)
		get_tree().root.add_child(credits)
	
	queue_free()
