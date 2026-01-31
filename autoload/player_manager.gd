extends Node

signal player_movement(is_enabled: bool)

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_resource: DialogueResource) -> void:
	player_movement.emit(false)

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	player_movement.emit(true)
