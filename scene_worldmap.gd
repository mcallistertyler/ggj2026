extends Node2D

@export var scene_car : OverworldCar

func _ready() -> void:
	scene_car.movement_allowed = true
