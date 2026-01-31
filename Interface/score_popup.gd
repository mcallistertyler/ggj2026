extends Node2D

@export var IconTexture : Texture2D

@onready var icon_texture = %IconTexture
@onready var amount_label = %AmountLabel
@onready var animation_player = %AnimationPlayer

func _ready():
	animation_player.play("fade_up")

func delete_self():
	queue_free()


func set_label(amount, icon):
	if amount <= 0:
		amount_label.text = str(amount)
		amount_label.add_theme_color_override("font_color", Color(0.663, 0.064, 0.19, 1.0))
	else:
		amount_label.text = "+" + str(amount)
	icon_texture.texture = icon
	
