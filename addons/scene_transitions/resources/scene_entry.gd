class_name SceneEntry
extends Resource

@export var scene_name: Enums.Scenes
@export_file("*.tscn") var scene_path: String

func is_valid() -> bool:
	return not scene_path.is_empty() and ResourceLoader.exists(scene_path)
