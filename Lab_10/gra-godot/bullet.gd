extends Node3D

@export var speed: float = 50.0
@export var lifetime: float = 0.4

func _process(delta: float):
	position.z -= speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	pass
