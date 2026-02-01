extends Area2D

@export var my_texture : CompressedTexture2D
@export var target_scene : Enums.Scenes
@export var cross_out : Sprite2D

func _ready():
	%MySprite.texture = my_texture
	connect("body_entered", Callable(self, "_on_body_entered"))
	cross_out.visible = false

func cross_off() -> void:
	cross_out.visible = true

func _on_body_entered(body: Node2D):
	if body.is_in_group(Groups.OVERWORLD_CAR_GROUP):
		var car : OverworldCar = body
		car.movement_allowed = false
	SceneManager.transition_to_scene(target_scene, false, TransitionType.Value.FADE_CIRCLE, TransitionType.Value.FADE_CIRCLE)
