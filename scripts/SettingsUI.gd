extends Control

onready var se_bus = AudioServer.get_bus_index("SoundEffects")
onready var music_bus = AudioServer.get_bus_index("Music")

func _ready() -> void:
	$SoundEffectsSlider.value = db2linear(AudioServer.get_bus_volume_db(se_bus))
	$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))

func _on_SoundEffectsSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(se_bus, linear2db(value))


func _on_MusicSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))
