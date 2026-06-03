extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal hp_changed(new_hp: int)
signal game_over
signal level_complete

signal enemy_killed
signal player_damaged

var score: int = 0
var lives: int = 3
var player_max_hp: int = 3
var player_hp: int = 3

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	enemy_killed.emit()

func player_hit(damage: int = 1) -> void:
	player_hp -= damage
	hp_changed.emit(player_hp)
	player_damaged.emit()
	
	if player_hp <= 0:
		lives -= 1
		lives_changed.emit(lives)
		
		if lives <= 0:
			game_over.emit()
		else:
			player_hp = player_max_hp
			hp_changed.emit(player_hp)

func reset() -> void:
	score = 0
	lives = 3
	player_hp = player_max_hp
	
	score_changed.emit(score)
	lives_changed.emit(lives)
	hp_changed.emit(player_hp)
