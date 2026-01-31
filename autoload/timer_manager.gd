extends Node

signal start_dialogue_timer
signal timer_manager_timeout(context)

enum Context { NONE, DIALOGUE, MINIGAME }

var current_context : Context

func _on_timeout_manager_timeout() -> void:
	timer_manager_timeout.emit(current_context)
	current_context = Context.NONE

func create_dialogue_timer(timeout_value: float, context: Context) -> void:
	get_tree().create_timer(timeout_value).timeout.connect(_on_timeout_manager_timeout)
	start_dialogue_timer.emit()
	current_context = context
