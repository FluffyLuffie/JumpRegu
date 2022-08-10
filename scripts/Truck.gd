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
				collision_layer = 1
				collision_mask = 1
	
func launch() -> void:
	is_active = true
	velocity = Vector2(20.0, -300.0)
	get_parent().remove_child(self)
	GameStates.game_vp.add_child(self)
	GameStates.player = self
	
func explode() -> void:
	GameStates.spawn_player(position)
	collision_layer = 0
	collision_mask = 0
	queue_free()
