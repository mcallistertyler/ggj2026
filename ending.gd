extends Node2D

@export var end_dialogue : DialogueResource
@onready var illustration = %Illustration
@onready var thanks_label = %ThanksLabel
@onready var animation_player = %AnimationPlayer

var dialogue_title : String = "bugged_ending"
var credz

func _ready():
	credz = CredzManager.credz
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	thanks_label.hide()
	animation_player.play("fade_in")
	%CredzLabel.text = str(credz)
	$ColorRect.show()
	set_assets()

func set_assets():
	if credz <= 0:
		dialogue_title = "terrible_ending"
		illustration.texture = load("res://assets/ending/endsplash_terrible.png")
	elif credz < 650:
		dialogue_title = "bad_ending"
		illustration.texture = load("res://assets/ending/endsplash_bad.png")
	elif credz < 1200:
		dialogue_title = "neutral_ending"
		illustration.texture = load("res://assets/ending/endsplash_neutral.png")
	else:
		dialogue_title = "good_ending"
		illustration.texture = load("res://assets/ending/endsplash_good.png")

func play_dialogue():
	var dialogue_balloon = DialogueManager.show_dialogue_balloon(end_dialogue, dialogue_title)



func _on_dialogue_ended(resource: DialogueResource):
	await get_tree().create_timer(2.0).timeout
	animation_player.play("show_thanks")
	
