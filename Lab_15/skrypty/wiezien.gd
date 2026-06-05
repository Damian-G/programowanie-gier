extends CharacterBody2D

@export var predkosc = 50.0
var kierunek = 1.0 

@onready var animacja = $AnimatedSprite2D 

func _ready() -> void:
	animacja.play("run")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = kierunek * predkosc
	move_and_slide()

	if is_on_wall():
		kierunek *= -1
		animacja.flip_h = (kierunek < 0)
