extends ScreenTransition

@export var tween_time : float = 2.0
@export var expanded_radius : float = 1.2
@export var contracted_radius : float = 0.0

var is_expanded : bool = false

func transition_to_scene() -> void:
	self.show()
	await circle_contract()

func scene_transitioned_to() -> void:
	self.show()
	await circle_expand()
	self.hide()

func circle_expand() -> void:
	var tween : Tween = create_tween()
	var aspect_ratio = self.get_rect().size.x / self.get_rect().size.y
	self.material.set_shader_parameter("aspect_ratio", aspect_ratio)
	tween.tween_method(func(value): self.material.set_shader_parameter("radius", value), contracted_radius, expanded_radius, tween_time)
	is_expanded = true
	await tween.finished

func circle_contract() -> void:
	var tween : Tween = create_tween()
	var aspect_ratio = self.get_rect().size.x / self.get_rect().size.y
	self.material.set_shader_parameter("aspect_ratio", aspect_ratio)
	tween.tween_method(func(value): self.material.set_shader_parameter("radius", value), expanded_radius, contracted_radius, tween_time)
	is_expanded = false
	await tween.finished

func update_loading_progress(_progress: float) -> void:
	pass
