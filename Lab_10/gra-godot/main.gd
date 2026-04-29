extends Node3D

var score: int = 0 

func add_score(amount: int):
	score += amount
	print("SCORE: ", score)
