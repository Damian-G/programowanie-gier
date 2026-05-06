extends CharacterBody2D

#maszyna stanów
enum Stany { IDLE, RUN }
var aktualny_stan = Stany.IDLE

@export var predkosc = 300.0
@onready var animacja = $AnimatedSprite2D

func _physics_process(_delta):
	var kierunek = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#zarządzanie stanami
	match aktualny_stan:
		Stany.IDLE:
			animacja.play("idle")
			if kierunek != Vector2.ZERO:
				aktualny_stan = Stany.RUN
		
		Stany.RUN:
			animacja.play("run")
			velocity = kierunek * predkosc
			
			#obracanie obrazka w lewo lub w prawo
			if kierunek.x > 0:
				animacja.flip_h = false
			elif kierunek.x < 0:
				animacja.flip_h = true
				
			if kierunek == Vector2.ZERO:
				aktualny_stan = Stany.IDLE
				velocity = Vector2.ZERO

	#ruch robota i kolizja
	move_and_slide()
