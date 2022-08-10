extends Area2D

var truck: KinematicBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	truck = get_node('../Truck')


# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if get_overlapping_bodies().size() > 0:
		truck.launch()
		collision_mask = 0
		get_overlapping_bodies()[0].queue_free()
		queue_free()
