extends Node2D

@export var end_dialogue : DialogueResource
@onready var illustration = %Illustration
@onready var thanks_label = %ThanksLabel
@onready var animation_player = %AnimationPlayer

var dialogue_title : String = "bugged_ending"
var credz
var glide_delay := 5.0 # seconds before gliding
var glide_active := false
var glide_elapsed := 0.0
var glide_start_y := 0.0
var glide_target_y := -200.0 # will be set dynamically
var glide_time := 3.0 # seconds to glide (will be set dynamically)

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
		AudioManager.play_music("ending-good")
		dialogue_title = "good_ending"
		illustration.texture = load("res://assets/ending/endsplash_good.png")

func play_dialogue():
	var dialogue_balloon = DialogueManager.show_dialogue_balloon(end_dialogue, dialogue_title)

func _on_dialogue_ended(resource: DialogueResource):
	await get_tree().create_timer(2.0).timeout
	animation_player.play("show_thanks")
	# Start glide after 5 seconds
	await get_tree().create_timer(glide_delay).timeout
	glide_active = true
	glide_elapsed = 0.0
	glide_start_y = thanks_label.position.y
	# Calculate target Y so label is fully outside the top of the window
	var label_height = thanks_label.size.y
	glide_target_y = -label_height - 20
	# Glide time based on distance and speed (e.g. 80 px/sec for slower)
	var distance = glide_start_y - glide_target_y
	var speed = 30.0 # px/sec (slower)
	glide_time = distance / speed

func _process(delta):
	if glide_active:
		glide_elapsed += delta
		if glide_elapsed <= glide_time:
			var t = glide_elapsed / glide_time
			thanks_label.position.y = lerp(glide_start_y, glide_target_y, t)
		else:
			thanks_label.position.y = glide_target_y
			glide_active = false
