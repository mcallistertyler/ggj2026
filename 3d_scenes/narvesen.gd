extends WalkableArea

@onready var background_sprite : Sprite3D = get_node("%BGImageSprite3D")

func _ready() -> void:
	background_sprite.visible = true
