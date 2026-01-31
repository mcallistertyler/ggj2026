extends Node

var credz: int = 0
signal credzIncreased(amount)
signal credzDecreased(amount)


func increaseCredz(amount: int):
	credz += amount
	credzIncreased.emit(amount)

func decreaseCredz(amount: int):
	credz -= amount
	credzDecreased.emit(amount)
	
	if credz < 0:
		die()


func die():
	#TODO: Failstate for the player? 
	print("player is out of credz")
	pass
	
