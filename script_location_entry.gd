extends Area2D

@export var my_texture : CompressedTexture2D

@export var my_name : String

func _ready():
	%MySprite.texture = my_texture
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("TODO Enter: " + my_name)
