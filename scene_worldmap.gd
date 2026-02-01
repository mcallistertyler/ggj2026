extends Node2D

@export var scene_car : OverworldCar

func _ready() -> void:
	scene_car.movement_allowed = true
	disable_exhausted_locations()
	check_win_conditions()

func disable_exhausted_locations():
	pass

func check_win_conditions():
	if GamestateManager.has_won():
		SceneManager.transition_to_scene()
