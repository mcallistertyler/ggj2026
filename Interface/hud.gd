extends CanvasLayer

const CREDZ_POPUP : PackedScene = preload("res://Interface/ScorePopup.tscn")

@export var add_icon : Texture2D
@export var subtract_icon : Texture2D

@onready var credz_label = %CredzLabel


@onready var viewport_size := get_viewport().get_visible_rect().size

var popup_spawn_position = Vector2(500,500)


func _ready() -> void:
	CredzManager.credz_decreased.connect(_on_credz_decreased)
	CredzManager.credz_increased.connect(_on_credz_increased)
	popup_spawn_position = Vector2(
		viewport_size.x - 20,
		viewport_size.y * 0.3
	)
	
	credz_label.text = str(CredzManager.credz)
	
	
func _on_credz_decreased(amount):
	credz_label.text = str(CredzManager.credz)

	var popup_instance = CREDZ_POPUP.instantiate()
	add_child(popup_instance)
	popup_instance.position = popup_spawn_position
	popup_instance.set_label(-abs(amount), subtract_icon)

func _on_credz_increased(amount):
	credz_label.text = str(CredzManager.credz)
	
	var popup_instance = CREDZ_POPUP.instantiate()
	add_child(popup_instance)
	popup_instance.position = popup_spawn_position
	popup_instance.set_label(amount, add_icon)
	
