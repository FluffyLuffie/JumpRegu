extends Node2D

func _on_Button_pressed() -> void:
	GameStates.spawn_player()
	GameStates.timer_active = true
	queue_free()
