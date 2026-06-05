extends Area2D

const EFEKT_WYRZUCONY = preload("res://sceny/efekt_wyrzucania.tscn")
var scena_wygranej = preload("res://sceny/wygrana.tscn")
var wyrzucam = false

@onready var dzwiek_wyrzucania = $DzwiekWyrzucania

func _ready():
	$EtykietaE.visible = false

func _on_body_entered(body):
	if body.name == "Gracz" and Global.w_plecaku > 0 and not wyrzucam:
		$EtykietaE.visible = true

func _on_body_exited(body):
	if body.name == "Gracz":
		$EtykietaE.visible = false

func _process(_delta):
	if $EtykietaE.visible and not wyrzucam:
		$EtykietaE.text = "[E] WYRZUC " + str(Global.w_plecaku) + " SMIECI"
		
		if Input.is_action_just_pressed("wyrzuc_smieci"):
			var gracz = get_tree().current_scene.find_child("Gracz", true, false)
			
			if gracz:
				wyrzucam = true
				$EtykietaE.visible = false
				
				var ile_smieci = Global.w_plecaku
				Global.w_plecaku = 0
				
				Global.smieci_wrzucone += ile_smieci
				print("Wyrzucono śmieci: ", ile_smieci, " | Postęp: ", Global.smieci_wrzucone, "/", Global.smieci_na_mapie)
				
				stworz_efekty_wyrzucania(ile_smieci, gracz)
				
				if Global.smieci_wrzucone >= Global.smieci_na_mapie:
					wywolaj_wygrana()
				
			else:
				Global.w_plecaku = 0
				$EtykietaE.visible = false

func stworz_efekty_wyrzucania(ile, obiekt_gracza):
	for i in range(ile):
		if not is_instance_valid(obiekt_gracza):
			break
			
		dzwiek_wyrzucania.pitch_scale = randf_range(0.9, 1.1)
		dzwiek_wyrzucania.play()
		
		var nowy_efekt = EFEKT_WYRZUCONY.instantiate()
		get_tree().current_scene.add_child(nowy_efekt)
		
		var losowy_numer = "%02d" % randi_range(1, 40)
		var tekstura = load("res://assets/smieci/Icon14_" + losowy_numer + ".png")
		
		nowy_efekt.start_animacji(obiekt_gracza.global_position, global_position, tekstura)
		
		await get_tree().create_timer(0.15).timeout
	
	wyrzucam = false

func wywolaj_wygrana():
	var instancja = scena_wygranej.instantiate()
	get_tree().current_scene.add_child(instancja)
	
	var gracz = get_tree().get_first_node_in_group("Gracz")
	
	if gracz:
		if "velocity" in gracz:
			gracz.velocity = Vector2.ZERO
			
		gracz.set_physics_process(false)
