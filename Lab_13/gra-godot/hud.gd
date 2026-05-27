extends CanvasLayer

@onready var wynik_label: Label = $WynikLabel
@onready var zycia_label: Label = $ZyciaLabel
@onready var hp_bar: ProgressBar = $ProgressBar

@onready var dzwiek_wroga: AudioStreamPlayer = $DzwiekWroga
@onready var dzwiek_gracza: AudioStreamPlayer = $DzwiekGracza

func _ready() -> void:
	hp_bar.max_value = GameManager.player_max_hp
	hp_bar.value = GameManager.player_hp
	wynik_label.text = "Wynik: " + str(GameManager.score)
	zycia_label.text = "Życia: " + str(GameManager.lives)
	
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.hp_changed.connect(_on_hp_changed)
	
	GameManager.game_over.connect(func(): get_tree().change_scene_to_file("res://game_over.tscn"))
	GameManager.level_complete.connect(func(): get_tree().change_scene_to_file("res://level_complete.tscn"))
	
	GameManager.enemy_killed.connect(_on_enemy_killed)
	GameManager.player_damaged.connect(_on_player_damaged)

func _on_score_changed(new_score: int) -> void:
	wynik_label.text = "Wynik: " + str(new_score)

func _on_lives_changed(new_lives: int) -> void:
	zycia_label.text = "Życia: " + str(new_lives)

func _on_hp_changed(new_hp: int) -> void:
	hp_bar.value = new_hp

func _on_enemy_killed() -> void:
	dzwiek_wroga.play()

func _on_player_damaged() -> void:
	dzwiek_gracza.play()
