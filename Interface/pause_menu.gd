extends CanvasLayer
@onready var resume_button = %Resume
@onready var exit_button = %Exit

@onready var icon = %Icon
@onready var status_label = %StatusLabel

# Hardcoded positions - dynamic layout calculation with control nodes was problematic
var position_A = Vector2(400.0, 300.0)
var position_B = Vector2(400.0, 375.0)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	visible = false
	calculate_status()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()

func toggle_pause():
	if visible == true:
		visible = false
	else:
		visible = true
		resume_button.grab_focus() # So player can immediately hit Enter/Confirm
		calculate_status()

func calculate_status():
	#TODO: Match the statuses to the actual gameplay
	var status = "BUG"
	if CredzManager.credz >= 2500:
		status = "LEGEND"
	elif CredzManager.credz >= 2000:
		status = "REAL ONE"
	elif CredzManager.credz >= 1500:
		status = "CHILL GUY"
	elif CredzManager.credz >= 1000:
		status = "NORMIE"
	elif CredzManager.credz >= 500:
		status = "NOBODY"
	else:
		print("Should have updated credz")
		status = "LOSER"
	status_label.text = status
	
func _on_resume_pressed() -> void:
	toggle_pause()


func _on_exit_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene("main_menu")



func focus_button(button):
	AudioManager.playSFX("menu_blink")
	button.add_theme_font_size_override("font_size", 50)

func unfocus_button(button):
	button.add_theme_font_size_override("font_size", 30)


func _on_resume_focus_entered() -> void:
	icon.position = position_A
	focus_button(resume_button)

func _on_resume_focus_exited() -> void:
	unfocus_button(resume_button)

func _on_exit_focus_entered() -> void:
	focus_button(exit_button)
	icon.position = position_B

func _on_exit_focus_exited() -> void:
	unfocus_button(exit_button)


func _on_dialogue_ended(resource: DialogueResource):
	resume_button.grab_focus()
	
