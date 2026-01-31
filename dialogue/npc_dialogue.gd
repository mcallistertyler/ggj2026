extends Node
class_name DialogueWithTimer

@export var dialogue_resource : DialogueResource
@export var dialogue_title : String
@export var is_timed : bool
@export var timeout_value : float = 2.0 # set this yourself

enum DialogueState { TIMED_OUT, GAME_SUCCESS, GAME_FAILED }

signal dialogue_state_result(response_tag)

func start_timer() -> void:
	TimerManager.create_dialogue_timer(timeout_value, TimerManager.Context.DIALOGUE)

func _on_responses_shown(_responses: Array) -> void:
	start_timer()

func _ready() -> void:
	TimerManager.timer_manager_timeout.connect(_on_timer_timeout)

func _on_timer_timeout(context: TimerManager.Context) -> void:
	if context == TimerManager.Context.DIALOGUE:
		dialogue_state_result.emit(DialogueState.TIMED_OUT)

func _on_response_selected(response: DialogueResponse) -> void:
	var response_tag = Enums.get_dialogue_response_tag(response)
	if response_tag:
		dialogue_state_result.emit(response_tag)

func start_dialogue() -> void:
	var dialogue_balloon : DialogueBaloon = DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title)
	await dialogue_balloon.ready
	if is_timed:
		dialogue_balloon.responses_shown.connect(_on_responses_shown)
		dialogue_balloon.responses_menu.response_selected.connect(_on_response_selected)
