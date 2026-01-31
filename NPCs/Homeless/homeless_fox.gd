extends NPC

@export var homeless_cup : Node3D
@export var homeless_cup_area_3d : Area3D

func _ready() -> void:
	super._ready()
	homeless_cup_area_3d.body_entered.connect(_on_homeless_cup_body_entered)
	
func _on_homeless_cup_body_entered(body: Node3D) -> void:
	if body.is_in_group(Groups.PLAYER_GROUP):
		fall_cup()
		
func fall_cup() -> void:
	homeless_cup.fall()
