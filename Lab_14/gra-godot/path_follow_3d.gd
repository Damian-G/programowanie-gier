extends PathFollow3D

#szybkość poruszania się po szynie
@export var rail_speed: float = 0.18

func _process(delta: float) -> void:
	progress_ratio += rail_speed * delta
