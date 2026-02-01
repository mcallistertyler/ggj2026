extends Node

var credz: int = 300
signal credz_increased(amount)
signal credz_decreased(amount)

# if it sees a negative number it calls decrease instead, yeah it makes no sense just roll with it
func increaseCredz(amount: int):
	if amount < 0:
		decreaseCredz(amount)
		return
	credz += amount
	credz_increased.emit(amount)

func decreaseCredz(amount: int):
	if amount < 0:
		credz += amount
		credz_decreased.emit(amount)
		if credz < 0:
			die()
		return
	credz -= amount
	credz_decreased.emit(amount)

	if credz < 0:
		die()


func die():
	#TODO: Failstate for the player? 
	print("player is out of credz")
	pass
	
