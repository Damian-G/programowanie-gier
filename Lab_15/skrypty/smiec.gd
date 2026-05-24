extends Area2D

var tekstury = []

func _ready():
	for i in range(1, 41):
		var numer = "%02d" % i 
		var sciezka = "res://assets/smieci/Icon14_" + numer + ".png"
		tekstury.append(load(sciezka))
	
	var losowy_obrazek = tekstury[randi() % tekstury.size()]
	$Sprite2D.texture = losowy_obrazek

func _on_body_entered(body):
	if body.name == "Gracz":
		if Global.w_plecaku < 4:
			Global.w_plecaku += 1
			print("Zebrano! Masz w plecaku: ", Global.w_plecaku)
			queue_free()
		else:
			print("Plecak pełny! Odnieś śmieci do kosza.")
