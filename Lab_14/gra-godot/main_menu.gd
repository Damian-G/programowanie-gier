extends Control

func _ready() -> void:
	$GrajButton.pressed.connect(_on_graj_pressed)

func _on_graj_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://main.tscn")
