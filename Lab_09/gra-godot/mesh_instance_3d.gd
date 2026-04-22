extends MeshInstance3D

@export var speed: float = 15.0
@export var LIMIT_X: float = 4.0
@export var LIMIT_Y: float = 4.0

func _process(delta: float) -> void:
	var input_dir_x = Input.get_axis("ui_left", "ui_right")
	var input_dir_y = Input.get_axis("ui_up", "ui_down")
	
	position.x += input_dir_x * speed * delta
	position.y -= input_dir_y * speed * delta 
	
	position.x = clamp(position.x, -LIMIT_X, LIMIT_X)
	position.y = clamp(position.y, -LIMIT_Y, LIMIT_Y)
