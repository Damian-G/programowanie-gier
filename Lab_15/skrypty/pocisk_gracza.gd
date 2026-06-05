extends Area2D

@export var predkosc = 700.0
var kierunek_ruchu = 1.0 

@onready var animacja_pocisku = $AnimatedSprite2D

func _ready() -> void:
	if kierunek_ruchu == -1.0:
		animacja_pocisku.flip_h = true
	else:
		animacja_pocisku.flip_h = false
	
	if animacja_pocisku.sprite_frames.has_animation("fly"):
		animacja_pocisku.play("fly")

func _physics_process(delta: float) -> void:
	position.x += kierunek_ruchu * predkosc * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Gracz"):
		return 
		
	if body.is_in_group("Wrogowie"):
		if body.has_method("oberwij"):
			body.oberwij()
	
	queue_free()
