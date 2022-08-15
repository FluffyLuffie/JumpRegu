extends Node2D

onready var settings:Control = $SettingsUI

func _ready() -> void:
	# warning-ignore:return_value_discarded
	$SettingsUI/Button.connect("pressed", self, "quit_game")

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		GameStates.paused = !GameStates.paused
		get_tree().paused = GameStates.paused
		
		settings.visible = !settings.visible

func quit_game():
	get_tree().quit()
