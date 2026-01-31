extends Node3D

class_name NPC
@export var npc_name : String
@export var sprite_3d : Sprite3D
@export var dialogue : DialogueWithTimer
@export var area_3d : Area3D

func _ready() -> void:
	if sprite_3d:
		sprite_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		
