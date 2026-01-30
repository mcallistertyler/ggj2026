@abstract
class_name ScreenTransition
extends ColorRect

var skip_loading_details : bool = false

@abstract
# animation to play when going from one scene to another
func transition_to_scene() -> void

@abstract
# animation to play when the new scene has been transitioned to
func scene_transitioned_to() -> void

@abstract
# update any loading indicators during async scene load
func update_loading_progress(progress: float) -> void
