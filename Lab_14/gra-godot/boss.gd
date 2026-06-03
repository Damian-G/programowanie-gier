extends Node3D

signal died

enum State { IDLE, ATTACK, RETREAT, DEATH }
var current_state: State = State.IDLE

@export_group("Stats")
@export var max_hp: int = 5
@onready var hp: int = max_hp

@export_group("Shooting")
@export var enemy_bullet_scene: PackedScene

var is_phase_2: bool = false
var state_timer: float = 0.0

@onready var hitbox1: Area3D = $HitboxPhase1
@onready var hitbox1_shape: CollisionShape3D = $HitboxPhase1/CollisionShape3D
@onready var hitbox2: Area3D = $HitboxPhase2
@onready var hitbox2_shape: CollisionShape3D = $HitboxPhase2/CollisionShape3D

func _ready() -> void:
	print("--- BOSS: Uruchamiam walkę z czystą maszyną stanów! ---")
	
	#faza 1 aktywna, faza 2 domyślnie wyłączona
	hitbox1_shape.disabled = false
	hitbox2_shape.disabled = true
	
	enter_state(State.IDLE)

func _process(delta: float) -> void:
	state_timer += delta

func enter_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	
	match current_state:
		State.IDLE:
			print("[FSM BOSS]: Stan -> IDLE")
			start_idle()
		State.ATTACK:
			print("[FSM BOSS]: Stan -> ATTACK")
			start_attack()
		State.RETREAT:
			print("[FSM BOSS]: Stan -> RETREAT")
			start_retreat()
		State.DEATH:
			print("[FSM BOSS]: Stan -> DEATH")
			start_death()

func start_idle() -> void:
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(func(): 
		if current_state != State.DEATH: 
			enter_state(State.ATTACK)
	)

func start_attack() -> void:
	if current_state == State.DEATH: return

	#logika strzału w stronę gracza
	if enemy_bullet_scene:
		var bullet = enemy_bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position
		
		#wykrywanie wektora lotu do przodu
		if bullet.has_method("set_direction"):
			bullet.set_direction(Vector3(0, 0, 1))
		elif "direction" in bullet:
			bullet.direction = Vector3(0, 0, 1)
		print("-> BOSS: Strzał w gracza!")
	
	#płynny ruch Tweenem w bok
	var tween = create_tween()
	var target_x = global_position.x + (2.5 if randf() > 0.5 else -2.5)
	tween.tween_property(self, "global_position:x", target_x, 4.0)
	tween.tween_callback(func(): 
		if current_state != State.DEATH: 
			enter_state(State.RETREAT)
	)

func start_retreat() -> void:
	if current_state == State.DEATH: return

	#wycofanie w głąb mapy
	var tween = create_tween()
	var target_z = global_position.z - 5.0
	tween.tween_property(self, "global_position:z", target_z, 1.5)
	tween.tween_callback(func(): 
		if current_state != State.DEATH: 
			enter_state(State.ATTACK)
	)

func take_hit(damage: int) -> void:
	if current_state == State.DEATH:
		return
		
	hp -= damage
	print("[KONSOLA BOSS] Trafienie! HP: ", hp, "/", max_hp)
	
	if hp <= max_hp / 2.0 and not is_phase_2:
		is_phase_2 = true
		#zamiana hitboxów
		hitbox1_shape.set_deferred("disabled", true)
		hitbox2_shape.set_deferred("disabled", false)
		print("!!! [FAZA 2] Zmiana na mniejszy HitboxPhase2!")
		
	if hp <= 0:
		enter_state(State.DEATH)

func start_death() -> void:
	print("!!! BOSS ZNISZCZONY !!!")
	
	#zapisanie pozycji bossa zanim go usuniemy
	var pozycja_smierci = global_position
	
	#wysłanie sygnału do HUD
	died.emit() 
	
	#eksplozja cząsteczkowa
	var explosion_scene = load("res://explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		
		#dodanie wybuchu do roota gry, żeby żył własnym życiem
		get_tree().root.add_child(explosion)
		
		#ustawiamy pozycję dokładnie tam, gdzie zginął boss
		explosion.global_position = pozycja_smierci
		
		#start czasteczek
		if explosion is GPUParticles3D or explosion is CPUParticles3D:
			explosion.emitting = true
		elif explosion.has_node("GPUParticles3D"):
			explosion.get_node("GPUParticles3D").emitting = true
			
		print("-> BOSS: Eksplozja stworzona na pozycji: ", pozycja_smierci)
		
	#usuniecie bossa ze swiata
	queue_free()
