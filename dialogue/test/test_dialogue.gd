extends Node2D

@export var dialogue_resource : DialogueResource
@export var dialogue_title : String

var dialogue_open : bool = false

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.got_dialogue.connect(_on_dialogue_line)
	DialogueManager.passed_title.connect(_on_dialogue_title)

func _on_dialogue_ended(resource: DialogueResource) -> void:
	print("Dialogue ended ", resource)

func _on_dialogue_started(resource: DialogueResource) -> void:
	print("Dialogue started ", resource)
	
func _on_dialogue_line(line) -> void:
	print("Dialogue line ", line)
	
func _on_dialogue_title(title) -> void:
	print("Dialogue title ", title)

func _on_spoke(letter: String, letter_index: int, speed: float) -> void:
	#print("Letter ", letter, "\nLetter index ", letter_index, "\nSpeed ", str(speed))
	pass

func _on_response_chosen(response: DialogueResponse) -> void:
	var response_tag = Enums.get_dialogue_response_tag(response)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and !dialogue_open:
		dialogue_open = true
		var dialogue_balloon : DialogueBaloon = DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
		await dialogue_balloon.ready
		dialogue_balloon.dialogue_label.spoke.connect(_on_spoke)
		dialogue_balloon.responses_menu.response_selected.connect(_on_response_chosen)
		await DialogueManager.dialogue_ended
		dialogue_open = false
