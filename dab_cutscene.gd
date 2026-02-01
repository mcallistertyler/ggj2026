extends CanvasLayer

class_name DabUpCutscene

#see assets/character_sprites/dabup
@export var npc_texture : Texture2D
@export var hand_texture : Texture2D
@export var success_texture : Texture2D


@onready var npc_portrait = %NPCPortrait
@onready var hand_image = %NPCHand
@onready var player_portait = %PlayerPortrait
@onready var success_portrait = %SuccessPortrait

@onready var animation_player = $AnimationPlayer

signal all_animations_finished

func _ready() -> void:
	if npc_texture == null:
		push_error("YOU FUCKER YOU FORGOT TO SET UP THE DAB SCENE")
	npc_portrait.texture = npc_texture
	hand_image.texture = hand_texture
	success_portrait.texture = success_texture

func play_dab_animation():
	$AnimationPlayer.play("dab_me_up")
	await $AnimationPlayer.animation_finished

func play_success_animation():
	$AnimationPlayer.play("dab_success")
	await $AnimationPlayer.animation_finished
