extends CharacterBody2D

@export var speed_partoli = 40.0
@export var speed_pogoni = 50.0
@export var dystans_patrolu = 30.0 
@export var obszar_wzroku = 70.0
@export var minimalny_dystans = 40.0

@export var max_zycia: int = 3
var aktualne_zycia: int = max_zycia

const KOLOR_ZIELONY = Color(0.0, 1.0, 0.0)
const KOLOR_ZOLTY = Color(1.0, 1.0, 0.0)
const KOLOR_CZERWONY = Color(1.0, 0.0, 0.0)

var warianty_statkow = ["wyglad1", "wyglad2", "wyglad3", "wyglad4", "wyglad5", "wyglad6", "wyglad7", "wyglad8", "wyglad9"]
var wylosowany_wyglad = "wyglad1" 

var scena_pocisku = preload("res://sceny/pocisk.tscn")
var pozycja_startowa: Vector2 
var kierunek_patrolu = 1.0 

enum Stany { PATROL, POGON, POWROT, DEAD }
var aktualny_stan = Stany.PATROL
var cel_gracz = null

@onready var timer_strzalu = $TimerStrzalu
@onready var marker_lufa = $Lufa
@onready var animacja = $AnimatedSprite2D
@onready var dzwiek_strzalu = $DzwiekStrzalu
@onready var pasek_zycia = $PasekZycia
@onready var efekt_eksplozji = $EfektEksplozji
@onready var kolizja = $CollisionShape2D
@onready var dzwiek_eksplozji = $EfektEksplozji/DzwiekEksplozji

func _ready() -> void:
	add_to_group("Wrogowie")
	await get_tree().process_frame 
	pozycja_startowa = global_position 
	wylosowany_wyglad = warianty_statkow.pick_random()
	animacja.play(wylosowany_wyglad)
	
	if pasek_zycia:
		pasek_zycia.max_value = max_zycia
		pasek_zycia.value = aktualne_zycia
		_aktualizuj_kolor_paska()

func _physics_process(delta: float) -> void:
	if aktualny_stan == Stany.DEAD: return
	
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

func oberwij():
	aktualne_zycia -= 1
	
	if pasek_zycia:
		pasek_zycia.value = aktualne_zycia
		_aktualizuj_kolor_paska()
	
	if aktualny_stan != Stany.POGON and aktualny_stan != Stany.DEAD:
		var gracze = get_tree().get_nodes_in_group("Gracz")
		if gracze.size() > 0:
			cel_gracz = gracze[0]
			aktualny_stan = Stany.POGON

	if aktualne_zycia <= 0:
		umiera()

func _aktualizuj_kolor_paska():
	if not pasek_zycia: return
	var procent_hp = float(aktualne_zycia) / float(max_zycia)
	if procent_hp >= 0.7:
		pasek_zycia.modulate = KOLOR_ZIELONY
	elif procent_hp >= 0.3:
		pasek_zycia.modulate = KOLOR_ZOLTY
	else:
		pasek_zycia.modulate = KOLOR_CZERWONY

func umiera():
	aktualny_stan = Stany.DEAD
	set_physics_process(false)
	
	if kolizja:
		kolizja.set_deferred("disabled", true)
		
	animacja.visible = false
	if pasek_zycia: 
		pasek_zycia.visible = false
	
	if efekt_eksplozji:
		efekt_eksplozji.visible = true
		efekt_eksplozji.play("explosion")
		
		if dzwiek_eksplozji:
			dzwiek_eksplozji.get_parent().remove_child(dzwiek_eksplozji)
			get_tree().current_scene.add_child(dzwiek_eksplozji)
			dzwiek_eksplozji.play()
			dzwiek_eksplozji.finished.connect(dzwiek_eksplozji.queue_free)
			
		await efekt_eksplozji.animation_finished
	
	queue_free()

func reset_celu():
	if aktualny_stan != Stany.DEAD:
		cel_gracz = null
		aktualny_stan = Stany.POWROT

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
	if not is_instance_valid(cel_gracz) or not cel_gracz.is_in_group("Gracz"):
		cel_gracz = null
		aktualny_stan = Stany.POWROT
		return
	var dystans = global_position.distance_to(cel_gracz.global_position)
	var kierunek = (cel_gracz.global_position - global_position).normalized()
	if dystans > minimalny_dystans:
		velocity = kierunek * speed_pogoni
	else:
		velocity = Vector2.ZERO
	animacja.flip_h = (cel_gracz.global_position.x < global_position.x)

func sprawdz_widocznosc_gracza():
	if is_instance_valid(cel_gracz):
		if not cel_gracz.is_in_group("Gracz") or global_position.distance_to(cel_gracz.global_position) > obszar_wzroku + 50 or not test_widocznosci_fizycznej(cel_gracz):
			cel_gracz = null
			aktualny_stan = Stany.POWROT
		return 
	var gracze = get_tree().get_nodes_in_group("Gracz")
	for g in gracze:
		if global_position.distance_to(g.global_position) < obszar_wzroku:
			if test_widocznosci_fizycznej(g):
				cel_gracz = g
				aktualny_stan = Stany.POGON
				break

func test_widocznosci_fizycznej(target_node: Node2D) -> bool:
	if not is_instance_valid(target_node): return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target_node.global_position)
	query.exclude = [self]
	query.collision_mask = 3
	var result = space_state.intersect_ray(query)
	return result and result.collider == target_node

func _on_timer_strzalu_timeout() -> void:
	if aktualny_stan == Stany.POGON and is_instance_valid(cel_gracz):
		if cel_gracz.is_in_group("Gracz"):
			scena_strzalu()

func scena_strzalu():
	if not is_instance_valid(cel_gracz): return
	dzwiek_strzalu.play()
	var p = scena_pocisku.instantiate()
	p.global_position = marker_lufa.global_position
	var punkt_celowania = cel_gracz.global_position + Vector2(0, -15)
	p.direction = (punkt_celowania - marker_lufa.global_position).normalized()
	p.wlasciciel_pocisku = self
	get_parent().add_child(p)

func _aktualizuj_animacje():
	animacja.play(wylosowany_wyglad)
	if animacja.flip_h: 
		marker_lufa.position.x = -abs(marker_lufa.position.x)
	else: 
		marker_lufa.position.x = abs(marker_lufa.position.x)
