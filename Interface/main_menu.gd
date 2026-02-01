extends Node2D

@onready var play_button = %Play
@onready var credits_button = %Credits
@onready var quit_button = %Quit
@onready var icon = %Icon

var icon_offset = Vector2(-40, 5)
var icon_offset_short = Vector2(250, 0)

func _ready():
	play_button.grab_focus()


func _on_play_pressed() -> void:
	AudioManager.playSFX("menu_blink")
	# Not yet implemented
	#SceneManager.transition_to_scene(Enums.Scenes.HJEMME_LEILIGHET)
	
func _on_credits_pressed() -> void:
	%CreditsPanel.show()
	%Back.grab_focus()
	await get_tree().process_frame
	await get_tree().process_frame
	icon.position = %Back.get_global_transform_with_canvas().origin + Vector2(0, (%Back.size.y / 2))
	icon.position += icon_offset_short
	

func _on_back_pressed() -> void:
	%CreditsPanel.hide()
	credits_button.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_play_focus_entered() -> void:
	focus_button(play_button)

func _on_play_focus_exited() -> void:
	unfocus_button(play_button)

func _on_credits_focus_entered() -> void:
	focus_button(credits_button)
	
func _on_credits_focus_exited() -> void:
	unfocus_button(credits_button)

func _on_quit_focus_entered() -> void:
	focus_button(quit_button)
	
func _on_quit_focus_exited() -> void:
	unfocus_button(quit_button)

func focus_button(button):
	AudioManager.playSFX("menu_blink")
	button.add_theme_font_size_override("font_size", 64)
	# Defer icon positioning to ensure button size has been updated after font size change
	await get_tree().process_frame
	await get_tree().process_frame
	icon.position = button.get_global_transform_with_canvas().origin + Vector2(0, (button.size.y / 2))
	icon.position += icon_offset

func unfocus_button(button):
	button.add_theme_font_size_override("font_size", 48)
