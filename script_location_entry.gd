extends Area2D

@export var my_texture : CompressedTexture2D
@export var target_scene : Enums.Scenes

func _ready():
	%MySprite.texture = my_texture
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	SceneManager.transition_to_scene(target_scene)
