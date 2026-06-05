extends Area2D

var tekstury = []
var zbierany = false
@onready var dzwiek_zebrania = $DzwiekZebrania

func _ready():
	Global.smieci_na_mapie += 1
	
	for i in range(1, 41):
		var numer = "%02d" % i 
		var sciezka = "res://assets/smieci/Icon14_" + numer + ".png"
		tekstury.append(load(sciezka))
	
	$Sprite2D.texture = tekstury[randi() % tekstury.size()]
	$Sprite2D.material.resource_local_to_scene = true

func _process(_delta):
	if not zbierany and $Sprite2D.material:
		var t = Time.get_ticks_msec() * 0.003
		var puls = 1.0 + sin(t) * 0.5
		$Sprite2D.material.set_shader_parameter("glow_intensity", puls)

func _on_body_entered(body):
	if body.name == "Gracz" and not zbierany:
		if Global.w_plecaku < 4:
			Global.w_plecaku += 1
			print("Zebrano! Ilość śmieci w plecaku: ", Global.w_plecaku)
			
			animuj_zbieranie(body)
		else:
			print("Plecak pełny! Odnieś śmieci do kosza.")

func animuj_zbieranie(gracz):
	zbierany = true
	
	dzwiek_zebrania.play()
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "global_position", gracz.global_position, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	tween.tween_property(self, "scale", Vector2(0.4, 0.4), 0.3)
	
	if $Sprite2D.material:
		tween.tween_property($Sprite2D.material, "shader_parameter/glow_intensity", 5.0, 0.2)

	tween.chain().tween_callback(zakoncz_i_usun)

func zakoncz_i_usun():
	$Sprite2D.visible = false
	
	if dzwiek_zebrania.playing:
		await dzwiek_zebrania.finished
		
	queue_free()
