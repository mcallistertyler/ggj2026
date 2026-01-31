extends Node

var credz: int = 500
signal credz_increased(amount)
signal credz_decreased(amount)


func increaseCredz(amount: int):
	credz += amount
	credz_increased.emit(amount)

func decreaseCredz(amount: int):
	credz -= amount
	credz_decreased.emit(amount)
	
	if credz < 0:
		die()


func die():
	#TODO: Failstate for the player? 
	print("player is out of credz")
	pass
	
