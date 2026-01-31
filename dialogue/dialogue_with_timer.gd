extends Node
class_name DialogueWithTimer

@export var dialogue_resource : DialogueResource
@export var dialogue_title : String
@export var timeout : float = 2.0 # set this yourself

enum DialogueState { TIMED_OUT, GAME_SUCCESS, GAME_FAILED }

signal dialogue_state_result(response_tag)

func start_timer() -> void:
	pass

func _on_got_dialogue(line: DialogueLine) -> void:
	if line.responses.size() > 0:
		start_timer()

func _ready() -> void:
	DialogueManager.got_dialogue.connect(_on_got_dialogue)

func _on_response_selected(response: DialogueResponse) -> void:
	var response_tag = Enums.get_dialogue_response_tag(response)
	if response_tag:
		dialogue_state_result.emit(response_tag)

func start_dialogue() -> void:
	var dialogue_balloon : DialogueBaloon = DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title)
	await dialogue_balloon.ready
	dialogue_balloon.responses_menu.response_selected.connect(_on_response_selected)
