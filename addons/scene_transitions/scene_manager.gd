extends CanvasLayer

signal transition_started
signal transition_completed

@export var scene_registry: SceneRegistry
@export var transitions: Array[ScreenTransition] = []
@export var default_transition_index: int = 0

var is_loading: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	if scene_registry:
		scene_registry.validate_scenes()

	# Hide all transitions on startup
	for transition in transitions:
		if transition:
			transition.hide()

	# Fade in from default transition on game start
	var default_transition = get_transition(default_transition_index)
	if default_transition:
		default_transition.show()
		default_transition.scene_transitioned_to()

func can_process_input() -> bool:
	return not is_transitioning

func get_transition(index: int) -> ScreenTransition:
	if index >= 0 and index < transitions.size():
		return transitions[index]
	if transitions.size() > 0:
		return transitions[0]
	return null

func get_scene_path(scene_name: Enums.Scenes) -> String:
	if scene_registry:
		return scene_registry.get_scene_path(scene_name)
	push_error("SceneManager: No scene registry configured and '%s' is not a path" % scene_name)
	return ""

func transition_to_scene(
	next_scene: Enums.Scenes,
	skip_loading_screen: bool = false,
	transition_out_index: int = -1,
	transition_in_index: int = -1
) -> void:
	# Use default if not specified
	if transition_out_index < 0:
		transition_out_index = default_transition_index
	if transition_in_index < 0:
		transition_in_index = default_transition_index

	# Guard against concurrent transitions
	if is_transitioning or is_loading:
		push_warning("SceneManager: Transition already in progress, ignoring request for '%s'" % next_scene)
		return

	is_transitioning = true
	is_loading = true
	transition_started.emit()

	var transition_out = get_transition(transition_out_index)
	if not transition_out:
		push_error("SceneManager: No valid transition_out, aborting")
		_reset_flags()
		return

	# Run transition out animation
	transition_out.skip_loading_details = skip_loading_screen
	transition_out.show()
	await transition_out.transition_to_scene()

	var scene_path = get_scene_path(next_scene)
	if scene_path.is_empty():
		_reset_flags()
		return

	var transition_in = get_transition(transition_in_index)
	if not transition_in:
		transition_in = transition_out

	if skip_loading_screen:
		await _load_scene_fast(scene_path, transition_in, transition_out)
	else:
		await _load_scene_async(scene_path, transition_in, transition_out)

func _load_scene_async(scene_path: String, transition_in: ScreenTransition, transition_out: ScreenTransition) -> void:
	var error = ResourceLoader.load_threaded_request(scene_path)

	if error != OK:
		push_error("SceneManager: Failed to start loading scene: %s" % scene_path)
		_reset_flags()
		return

	while true:
		var progress_array: Array = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress_array)
		var progress = progress_array[0] if progress_array.size() > 0 else 0.0
		transition_in.update_loading_progress(progress)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			is_loading = false
			var resource = ResourceLoader.load_threaded_get(scene_path)

			if resource and resource is PackedScene:
				get_tree().change_scene_to_packed(resource)
				await _finish_transition(transition_in, transition_out)
			else:
				push_error("SceneManager: Failed to load scene resource")
				_reset_flags()
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("SceneManager: Error loading scene: %s" % scene_path)
			_reset_flags()
			break

		await get_tree().process_frame

func _load_scene_fast(scene_path: String, transition_in: ScreenTransition, transition_out: ScreenTransition) -> void:
	var resource = load(scene_path)
	is_loading = false

	if resource and resource is PackedScene:
		get_tree().change_scene_to_packed(resource)
		await _finish_transition(transition_in, transition_out)
	else:
		push_error("SceneManager: Failed to load scene resource")
		_reset_flags()

func _finish_transition(transition_in: ScreenTransition, transition_out: ScreenTransition) -> void:
	transition_in.show()
	if transition_out != transition_in:
		transition_out.hide()

	await transition_in.scene_transitioned_to()
	is_transitioning = false
	transition_completed.emit()

func _reset_flags() -> void:
	is_loading = false
	is_transitioning = false
