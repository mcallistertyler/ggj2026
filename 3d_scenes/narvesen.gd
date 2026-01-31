extends WalkableArea


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body was entered", body)
