extends Control

func _ready() -> void:
	$WynikLabel.text = "Twój wynik: " + str(GameManager.score)
	$MenuButton.pressed.connect(_on_menu_pressed)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
