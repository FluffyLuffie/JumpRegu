extends Node

var fullscreen:bool = true
var resolution_index:int = 2
var resolutions:PoolVector2Array = [Vector2(640, 360), Vector2(1280, 720), Vector2(1920, 1080)]

func _ready() -> void:
	OS.current_screen = 1
	OS.window_fullscreen = true
	get_viewport().size = resolutions[resolution_index]
	OS.window_size = resolutions[resolution_index]
	
	AudioServer.set_bus_volume_db(1, -10.0)
	AudioServer.set_bus_volume_db(2, -10.0)
