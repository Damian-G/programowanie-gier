extends Node3D

#trzymanie wszystkich punktów
var score: int = 0 

func add_score(amount: int):
	#dorzucanie punktów do puli
	score += amount
	#aktualny wynik
	print("SCORE: ", score)
