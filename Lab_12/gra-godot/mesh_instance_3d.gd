extends MeshInstance3D

var hp: int = 3 #życie
var is_invincible: bool = false #flaga do beczki

#zmienne ruchu
@export var speed: float = 5.0
@export var LIMIT_X: float = 3.5
@export var LIMIT_Y: float = 2.0

#zmienne strzelania
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
var _shoot_cooldown: float = 0.0

func _ready() -> void:
	#dodanie do grupy, żeby wrogowie mogli w nas celować
	add_to_group("player")

func _process(delta: float) -> void:
	#logika ruchu
	var input_dir_x = Input.get_axis("ui_left", "ui_right")
	var input_dir_y = Input.get_axis("ui_up", "ui_down")
	
	#limity
	position.x += input_dir_x * speed * delta
	position.y -= input_dir_y * speed * delta 
	
	position.x = clamp(position.x, -LIMIT_X, LIMIT_X)
	position.y = clamp(position.y, -LIMIT_Y, LIMIT_Y)
	
	#odpalanie beczki
	if Input.is_action_just_pressed("ui_select") and not is_invincible:
		start_barrel_roll()
	
	#logika strzelania
	_shoot_cooldown -= delta
	if Input.is_action_pressed("ui_accept") and _shoot_cooldown <= 0:
		shoot()
		_shoot_cooldown = fire_rate

#beczka
func start_barrel_roll():
	is_invincible = true
	print("BECZKA: odporność")
	
	$AnimationPlayer.play("barrel_roll")
	
	await $AnimationPlayer.animation_finished
	
	is_invincible = false
	rotation.z = 0
	print("BECZKA: koniec odporności")

#kolizja i hp
func _on_body_entered(body: Node3D):
	if body is StaticBody3D:
		take_damage(1)

func take_damage(amount: int):
	#jak trwa beczka, to unikamy dmg
	if is_invincible:
		print("UNIK! Beczka zablokowała obrażenia.")
		return
		
	hp -= amount
	print("KOLIZJA! Pozostałe HP: ", hp)

#funkcja pomocnicza tworzenia pocisku
func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		#wrzucenie pocisku do głównego drzewa gry, żeby nie latał razem ze statkiem
		get_tree().root.add_child(bullet)
		
		#ustawienie pozycji startowej pocisku
		bullet.global_position = global_position
		
		#nadanie kierunku pociskowi
		if "direction" in bullet:
			bullet.direction = Vector3(0, 0, -1)
