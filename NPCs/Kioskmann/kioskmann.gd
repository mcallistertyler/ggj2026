extends NPC

@export var dab_up : DabUpMinigame
var player_within_area : bool = false
var dialogue_started : bool = false
var minigame_played : bool = false

var response_timeout_value : float

func _ready():
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	if dab_up:
		dab_up.dab_up_completed.connect(_on_minigame_completed)
	if dialogue:
		response_timeout_value = dialogue.timeout_value

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == dialogue.dialogue_resource:
		# HACK :)
		await get_tree().create_timer(0.3).timeout
		dialogue_started = false

func _on_responses_shown(_responses: Array) -> void:
	if response_timeout_value > 0:
		TimerManager.create_dialogue_timer(response_timeout_value, TimerManager.Context.DIALOGUE)

func _on_response_chosen(response: DialogueResponse) -> void:
	TimerManager.cancel_timer()
	var response_type = Enums.get_dialogue_response_tag(response)
	# start dabupgame
	dab_up.open(response_type)
	# Show response based on minigame result
	# Parent.gd

func _on_minigame_completed(score: int, result: DabUpMinigame.DabUpCompletion) -> void:
	minigame_played = true
	CredzManager.increaseCredz(result)
	
	#continue dialogue based on result
	if result == DabUpMinigame.DabUpCompletion.PASS:
	# TODO: create FAIL, PASS and PASS_HARD to trigger loss, win and big win dialogues
		pass

func _process(_delta: float) -> void:
	if player_within_area and !dialogue_started and Input.is_action_just_pressed("ui_accept") and !minigame_played:
		dialogue_started = true
		var dialogue_balloon = DialogueManager.show_dialogue_balloon(dialogue.dialogue_resource, dialogue.dialogue_title)
		await dialogue_balloon.ready
		#dialogue_balloon.responses_shown.connect(_on_responses_shown)
		dialogue_balloon.responses_menu.response_selected.connect(_on_response_chosen)

func _on_body_entered(body: Node3D):
	if body.is_in_group(Groups.PLAYER_GROUP):
		player_within_area = true
		if body is PlayerCharacterBody3D:
			body.show_interact()

		
func _on_body_exited(body: Node3D):
	if body.is_in_group(Groups.PLAYER_GROUP):
		player_within_area = false
		if body is PlayerCharacterBody3D:
			body.hide_interact()
