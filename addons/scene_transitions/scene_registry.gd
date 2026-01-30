class_name SceneRegistry
extends Resource

@export var transitionable_scenes : Array[SceneEntry] = []

func get_scene_path(scene_name: Enums.Scenes) -> String:
	for entry in transitionable_scenes:
		if entry.scene_name == scene_name:
			if not entry.is_valid():
				push_error("SceneRegistry: Invalid path for '%s': %s" % [scene_name, entry.scene_path])
			return entry.scene_path
	push_error("SceneRegistry: Unknown scene '%s'" % scene_name)
	return ""
	
func validate_scenes() -> bool:
	var valid : bool = true
	var seen_definitions : Array[Enums.Scenes] = []
	for entry in transitionable_scenes:
		if entry.scene_name in seen_definitions:
			push_error("SceneRegistry: Duplicate scene enum '%s'" % Enums.Scenes.keys()[entry.scene_name])
			valid = false
		else:
			seen_definitions.append(entry.scene_name)
		if not entry.is_valid():
			push_error("Scene Registry: '%s' has an invalid path: '%s'" % [entry.scene_name, entry.scene_path])
			valid = false
	return valid
	
func has_scene(scene_name: Enums.Scenes) -> bool:
	for entry in transitionable_scenes:
		if entry.scene_name == scene_name:
			return true
	return false
