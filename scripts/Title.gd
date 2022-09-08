extends Node2D

func _on_Button_pressed() -> void:
	GameStates.spawn_player()
	GameStates.timer_active = true
	var music: AudioStreamPlayer =  get_node("/root/GameWorld/Music")
	music.stream = load("res://music/rainyWalk.ogg")
	music.play()
	queue_free()
