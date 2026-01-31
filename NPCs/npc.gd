extends Node3D

class_name NPC
@export var npc_name : String
@export var sprite_3d : SpriteBase3D
@export var dialogue : DialogueWithTimer
@export var area_3d : Area3D

@export var dab_up : DabUpMinigame
@export var win_hard_dialogue : DialogueWithTimer
@export var win_easy_dialogue : DialogueWithTimer
@export var lose_dialogue : DialogueWithTimer

var player_within_area : bool = false
var dialogue_started : bool = false
var minigame_played : bool = false

var response_timeout_value : float

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	dab_up.dab_up_completed.connect(_on_minigame_completed)
	response_timeout_value = dialogue.timeout_value
	if sprite_3d:
		sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	else:
		push_error("No sprite 3d detected!")

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == dialogue.dialogue_resource:
		await get_tree().create_timer(0.3).timeout
		dialogue_started = false

func _on_response_chosen(response: DialogueResponse) -> void:
	TimerManager.cancel_timer()
	var response_type = Enums.get_dialogue_response_tag(response)
	dab_up.open(response_type)

# Useless
func _on_responses_shown(_responses: Array) -> void:
	if response_timeout_value > 0:
		TimerManager.create_dialogue_timer(response_timeout_value, TimerManager.Context.DIALOGUE)

func _on_minigame_completed(score: int, result: DabUpMinigame.DabUpCompletion) -> void:
	minigame_played = true
	CredzManager.increaseCredz(score)
	var dialogue_to_use : DialogueWithTimer
	if result == DabUpMinigame.DabUpCompletion.PASS_EASY:
		dialogue_to_use = win_easy_dialogue
	elif result == DabUpMinigame.DabUpCompletion.PASS_HARD:
		dialogue_to_use = win_hard_dialogue
	else:
		dialogue_to_use = lose_dialogue
	var dialogue_balloon = DialogueManager.show_dialogue_balloon(dialogue_to_use.dialogue_resource, dialogue_to_use.dialogue_title)
	await dialogue_balloon.ready

func _process(delta: float) -> void:
	if player_within_area and !dialogue_started and Input.is_action_just_pressed("ui_accept") and !minigame_played:
		dialogue_started = true
		var dialogue_balloon = DialogueManager.show_dialogue_balloon(dialogue.dialogue_resource, dialogue.dialogue_title)
		await dialogue_balloon.ready
		#dialogue_balloon.responses_shown.connect(_on_responses_shown)
		dialogue_balloon.responses_menu.response_selected.connect(_on_response_chosen)

func _on_body_entered(body: Node3D):
	if minigame_played:
		return
	if body.is_in_group(Groups.PLAYER_GROUP):
		player_within_area = true
		if body is PlayerCharacterBody3D:
			body.show_interact()

		
func _on_body_exited(body: Node3D):
	if body.is_in_group(Groups.PLAYER_GROUP):
		player_within_area = false
		if body is PlayerCharacterBody3D:
			body.hide_interact()
