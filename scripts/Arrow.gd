extends Sprite

var original_y: float
var time_passed: float = 0.0

func _ready() -> void:
	original_y = position.y

func _process(delta: float) -> void:
	position.y = original_y + sin(time_passed * 3) * 2
	time_passed += delta
