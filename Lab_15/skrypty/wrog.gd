extends CharacterBody2D

@export var speed_partoli = 40.0
@export var speed_pogoni = 50.0
@export var dystans_patrolu = 30.0 
@export var obszar_wzroku = 70.0
@export var minimalny_dystans = 30.0

var scena_pocisku = preload("res://sceny/pocisk.tscn")
var pozycja_startowa: Vector2 
var kierunek_patrolu = 1.0 

enum Stany { PATROL, POGON, POWROT }
var aktualny_stan = Stany.PATROL
var cel_gracz = null

@onready var timer_strzalu = $TimerStrzalu
@onready var marker_lufa = $Lufa
@onready var animacja = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("Wrogowie")
	await get_tree().process_frame 
	pozycja_startowa = global_position 
	aktualny_stan = Stany.PATROL

func _physics_process(delta: float) -> void:
	match aktualny_stan:
		Stany.PATROL: 
			ruch_patrol(delta)
			if not timer_strzalu.is_stopped(): timer_strzalu.stop()
			
		Stany.POGON: 
			ruch_pogon(delta)
			if timer_strzalu.is_stopped():
				timer_strzalu.start(1.0)
				
		Stany.POWROT: 
			ruch_powrot(delta)
			if not timer_strzalu.is_stopped(): timer_strzalu.stop()
	
	move_and_slide()
	sprawdz_widocznosc_gracza()
	_aktualizuj_animacje()

func ruch_powrot(delta: float):
	var wektor_do_startu = pozycja_startowa - global_position
	if wektor_do_startu.length() < 5.0:
		global_position = pozycja_startowa
		velocity = Vector2.ZERO
		aktualny_stan = Stany.PATROL
		kierunek_patrolu = 1.0
		return
	velocity = wektor_do_startu.normalized() * speed_partoli
	animacja.flip_h = (velocity.x < 0)

func ruch_patrol(delta: float):
	var dystans_od_bazy = global_position.x - pozycja_startowa.x
	if abs(dystans_od_bazy) > dystans_patrolu:
		kierunek_patrolu *= -1 
	velocity.x = kierunek_patrolu * speed_partoli
	velocity.y = 0 
	animacja.flip_h = (velocity.x < 0)

func ruch_pogon(delta: float):
	if not is_instance_valid(cel_gracz) or ("aktualny_stan" in cel_gracz and cel_gracz.aktualny_stan == 4):
		cel_gracz = null
		aktualny_stan = Stany.POWROT
		return
	
	var kierunek = (cel_gracz.global_position - global_position).normalized()
	velocity = kierunek * speed_pogoni
	animacja.flip_h = (cel_gracz.global_position.x < global_position.x)

func sprawdz_widocznosc_gracza():
	# Najpierw spróbujmy znaleźć gracza, jeśli go nie mamy
	var gracze = get_tree().get_nodes_in_group("Gracz")
	var potencjalny_cel = null
	
	for g in gracze:
		if "aktualny_stan" in g and g.aktualny_stan == 4: continue
		var dystans = global_position.distance_to(g.global_position)
		if dystans < obszar_wzroku:
			if test_widocznosci_fizycznej(g):
				potencjalny_cel = g
				break # Znaleźliśmy, nie szukamy dalej
	
	if is_instance_valid(cel_gracz):
		if ("aktualny_stan" in cel_gracz and cel_gracz.aktualny_stan == 4) or global_position.distance_to(cel_gracz.global_position) > obszar_wzroku + 50 or not test_widocznosci_fizycznej(cel_gracz):
			cel_gracz = null
			aktualny_stan = Stany.POWROT
	elif potencjalny_cel:
		cel_gracz = potencjalny_cel
		aktualny_stan = Stany.POGON

func test_widocznosci_fizycznej(target_node: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target_node.global_position)
	
	query.exclude = [self]
	
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	if result:
		if result.collider.is_in_group("Gracz"):
			return true
	
	return false

func _on_timer_strzalu_timeout() -> void:
	if aktualny_stan == Stany.POGON and is_instance_valid(cel_gracz):
		scena_strzalu()

func scena_strzalu():
	var p = scena_pocisku.instantiate()
	p.global_position = marker_lufa.global_position
	var srodek_gracza = cel_gracz.global_position + Vector2(0, -20)
	p.direction = (srodek_gracza - marker_lufa.global_position).normalized()
	p.wlasciciel_pocisku = self
	get_parent().add_child(p)

func _aktualizuj_animacje():
	animacja.play("fly")
