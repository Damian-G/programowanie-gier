extends Node3D

signal died(points: int)

@export_group("Stats")

#życia wroga
@export var hp: int = 2

#score za 1 wroga
@export var score_value: int = 100

@export_group("Sway Movement")
#szerokosc bujania się wroga
@export var sway_amplitude: float = 3.0
#szybkość bujania się
@export var sway_period: float = 2.0

@export_group("Shooting")

@export var bullet_scene: PackedScene
#strzał wroga co x sekund
@export var shoot_interval: float = 2.5
#ilcznik czasu strzelania wroga
var _shoot_timer: float = 0.0

func _ready():
	#podpięcie hitboxa
	if has_node("Hitbox"):
		$Hitbox.area_entered.connect(_on_area_entered)
	else:
		push_error("Błąd: Wróg nie ma węzła Hitbox (Area3D)!")
	
	#ruch wroga
	setup_sway()

func setup_sway():
	#płynna animacja ruchu lewo-prawo
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	#bujanie się relatywnie do miejsca, w którym wróg się zespawnował
	tween.tween_property(self, "position:x", sway_amplitude, sway_period).as_relative()
	tween.tween_property(self, "position:x", -sway_amplitude * 2, sway_period * 2).as_relative()
	tween.tween_property(self, "position:x", sway_amplitude, sway_period).as_relative()

func _process(delta):
	#odliczanie czasu do kolejnego strzału
	_shoot_timer += delta
	if _shoot_timer >= shoot_interval:
		#reset stopera
		_shoot_timer = 0.0
		#strzał
		shoot_at_player() 

func shoot_at_player():
	#szukanie gracza w grupie player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and bullet_scene:
		#bierzemy pierwszego gracza z brzegu
		var player = players[0]
		#obliczanie wektora w stronę gracza
		var dir = (player.global_position - global_position).normalized()
		
		#tworzymy pocisk i wrzucamy go na scenę
		var b = bullet_scene.instantiate()
		get_tree().root.add_child(b)
		b.global_position = global_position
		
		#określenie w którą stronę pocisk ma lecieć
		if "direction" in b:
			b.direction = dir

		#ustawianie fizyki
		var bullet_area = b.get_node("Area3D")
		
		if bullet_area:
			bullet_area.set_collision_layer_value(3, false) #wyłączenie layera pocisku gracza
			bullet_area.set_collision_layer_value(4, true)  #włączenie layera pocisku wroga
			bullet_area.set_collision_mask_value(1, true)   #trafianie tylko w gracza layer 1
			bullet_area.set_collision_mask_value(2, false)  #wróg nie trafia w swoich

func _on_area_entered(_area: Area3D):
	#obsługa trafienia, jak trafienie to -1hp
	hp -= 1
	print("Wróg trafiony! HP: ", hp)
	
	#jak hp 0 to wróg ginie
	if hp <= 0:
		die()
		
func die():
	#wysłanie sygnału o punktach, zanim znikniemy
	died.emit(score_value)
	print("Wróg zniszczony!")
	#usuwanie wroga
	queue_free()
