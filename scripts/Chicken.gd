extends Area2D

func _ready() -> void:
	if GameStates.chicken_cooked:
		$AnimationPlayer.stop()
		$Sprite.region_rect.position.x = 32

func _on_Chicken_body_entered(body: Node) -> void:
	if body.collision_layer == 2:
		$AnimationPlayer.stop()
		$Sprite.region_rect.position.x = 32
		GameStates.chicken_cooked = true
