extends ScreenTransition

@export var fade_duration: float = 0.5

func transition_to_scene() -> void:
	show()
	modulate.a = 0.0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	await tween.finished

func scene_transitioned_to() -> void:
	show()
	modulate.a = 1.0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween.finished
	hide()

func update_loading_progress(_progress: float) -> void:
	pass
