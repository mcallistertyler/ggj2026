extends Area2D

@export var my_texture : CompressedTexture2D

func _ready():
	%MySprite.texture = my_texture
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("HIT HIT HIT")
