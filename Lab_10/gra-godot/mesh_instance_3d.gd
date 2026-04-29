extends MeshInstance3D

#zmienne ruchu
@export var speed: float = 5.0
@export var LIMIT_X: float = 4.0
@export var LIMIT_Y: float = 4.0

#zmienne strzelania
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
var _shoot_cooldown: float = 0.0


func _process(delta: float) -> void:
	#logika ruchu
	var input_dir_x = Input.get_axis("ui_left", "ui_right")
	var input_dir_y = Input.get_axis("ui_up", "ui_down")
	
	position.x += input_dir_x * speed * delta
	position.y -= input_dir_y * speed * delta 
	
	position.x = clamp(position.x, -LIMIT_X, LIMIT_X)
	position.y = clamp(position.y, -LIMIT_Y, LIMIT_Y)
	
	#logika strzelania
	_shoot_cooldown -= delta
	
	if Input.is_action_pressed("ui_accept") and _shoot_cooldown <= 0:
		shoot()
		_shoot_cooldown = fire_rate

#funckja pomocnicza ttworzenia pocisku
func shoot():
	if bullet_scene: #czy scenap rzypisana
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		#ustawienie pozycji pocisku na globalną pozycję statku
		bullet.global_transform = global_transform
