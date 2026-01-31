extends NPC

var player_within_area : bool = false
var dialogue_started : bool = false

var response_timeout_value : float

func _ready():
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	if dialogue:
		response_timeout_value = dialogue.timeout_value

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == dialogue.dialogue_resource:
		# HACK :)
		await get_tree().create_timer(0.3).timeout
		dialogue_started = false

func _on_responses_visible(dialogue_balloon: DialogueBaloon) -> void:
	if dialogue_balloon.responses_menu.visible and response_timeout_value != null:
		TimerManager.create_dialogue_timer(response_timeout_value, TimerManager.Context.DIALOGUE)

func _on_response_chosen(response: DialogueResponse) -> void:
	print("Received response", response)

func _process(_delta: float) -> void:
	if player_within_area and !dialogue_started and Input.is_action_just_pressed("ui_accept"):
		print("starting dialogues")
		dialogue_started = true
		var dialogue_balloon = DialogueManager.show_dialogue_balloon(dialogue.dialogue_resource, dialogue.dialogue_title)
		await dialogue_balloon.ready
		dialogue_balloon.responses_menu.visibility_changed.connect(_on_responses_visible.bind(dialogue_balloon))
		dialogue_balloon.responses_menu.response_selected.connect(_on_response_chosen)	
func _on_body_entered(body: Node3D):
	print("body entered: ", body.name, " layer: ", body.collision_layer, " groups: ", body.get_groups())
	if body.is_in_group(Groups.PLAYER_GROUP):
		player_within_area = true
		
func _on_body_exited(body: Node3D):
	print("body exited")
	if body.is_in_group(Groups.PLAYER_GROUP):
		player_within_area = false
