extends Area2D

func _ready() -> void:
	$White.global_position = Vector2.ZERO

# warning-ignore:unused_argument
func _on_BigChicken_body_entered(body: Node) -> void:
	collision_layer = 0
	collision_mask = 0
	GameStates.cutscene = true
	GameStates.player.velocity.x = 0.0
	$AnimationPlayer.play('flash')
	
func open():
	$Sprite.modulate.a = 0.0
	GameStates.player.game_clear()
	GameStates.player.state = Regu.State.zenoJump
