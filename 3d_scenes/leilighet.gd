extends Node3D


@export var intro_dialogue : DialogueResource

func _ready():
	await get_tree().create_timer(2.0).timeout
	var dialogue_balloon = DialogueManager.show_dialogue_balloon(intro_dialogue, "start")
