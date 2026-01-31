extends Node2D

@export var audio_path : String

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioManager
