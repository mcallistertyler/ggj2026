extends Node

signal start_dialogue_timer
signal timer_manager_timeout(context)

enum Context { NONE, DIALOGUE, MINIGAME }

var current_context : Context
var current_timer : SceneTreeTimer

func _on_timeout_manager_timeout() -> void:
	timer_manager_timeout.emit(current_context)
	current_context = Context.NONE
	current_timer = null

func create_dialogue_timer(timeout_value: float, context: Context) -> void:
	current_timer = get_tree().create_timer(timeout_value)
	current_timer.timeout.connect(_on_timeout_manager_timeout)
	start_dialogue_timer.emit()
	current_context = context

func get_time_left() -> float:
	if current_timer:
		return current_timer.time_left
	return 0.0
