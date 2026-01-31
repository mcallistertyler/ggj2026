extends Node

var credz: int = 100
signal credz_increased(amount)
signal credz_decreased(amount)


func increaseCredz(amount: int):
	if amount < 0:
		decreaseCredz(amount)
	credz += amount
	credz_increased.emit(amount)

func decreaseCredz(amount: int):
	if amount < 0:
		credz += amount
	credz -= amount
	credz_decreased.emit(amount)
	
	if credz < 0:
		die()


func die():
	#TODO: Failstate for the player? 
	print("player is out of credz")
	pass
	
