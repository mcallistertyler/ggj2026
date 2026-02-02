extends Node3D
class_name Intro

@export var hud: HUD

@export var intro_dialogue : DialogueResource

var total_seconds_held : float = 0.0
var held_seconds : float = GamestateManager.hold_skip_time
var skipped_cutscene : bool = false

func _ready():
	await get_tree().create_timer(1.0).timeout
	var dialogue_balloon = DialogueManager.show_dialogue_balloon(intro_dialogue, "start")

func _process(delta: float) -> void:
	if !skipped_cutscene:
		if Input.is_action_pressed("skip_dialogue"):
			if hud:
				if !hud.skip_label.being_held:
					hud.skip_label.set_held(true)
			total_seconds_held += delta
		if Input.is_action_just_released("skip_dialogue"):
			if hud:
				if hud.skip_label.being_held:
					hud.skip_label.set_held(false)
			total_seconds_held = 0.0
		if total_seconds_held >= held_seconds:
			skipped_cutscene = true
			SceneManager.transition_to_scene(Enums.Scenes.GANGEN, TransitionType.Value.FADE_BLACK, TransitionType.Value.FADE_BLACK)
