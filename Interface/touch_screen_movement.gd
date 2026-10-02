extends CanvasLayer


@export var always_visible : bool = false

@export_range(0.0, 1.0) var dead_zone : float = 0.2

@export var grab_margin : float = 1.25

@onready var pad : Node2D = $Pad
@onready var base : Sprite2D = $Pad/Base
@onready var nub : Sprite2D = $Pad/Nub

@onready var interact_button : TouchScreenButton = get_node("%InteractButton")
@onready var pause_button : TouchScreenButton = get_node("%PauseButton")

@onready var radius : float = base.texture.get_width() / 2.0

var is_touchscreen_device : bool = DeviceInfo.is_touch_device()
var touch_index : int = -1
var pressed_actions : Dictionary[StringName, bool] = {}

var _pause_open : bool = false
var _dialogue_active : bool = false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	GamestateManager.pause_opened.connect(_on_pause_opened)
	GamestateManager.pause_closed.connect(_on_pause_closed)
	# Input stays enabled even while hidden, otherwise the toggle key is never delivered.
	set_process_input(true)
	_apply_visibility()

func _apply_visibility() -> void:
	var wanted : bool = always_visible or is_touchscreen_device or GamestateManager.touch_ui_override
	var should_show : bool = wanted and not _pause_open and not _dialogue_active
	if should_show == visible:
		return
	visible = should_show
	if not visible:
		# Never leave move_* actions held when the pad disappears mid-drag.
		release_joystick()

func _on_pause_opened() -> void:
	_pause_open = true
	_apply_visibility()

func _on_pause_closed() -> void:
	_pause_open = false
	_apply_visibility()

func _on_dialogue_started(_resource) -> void:
	_dialogue_active = true
	_apply_visibility()

func _on_dialogue_ended(_resource) -> void:
	_dialogue_active = false
	_apply_visibility()

func _exit_tree() -> void:
	release_joystick()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_touch_controls"):
		# Locked on wherever touch is the only input: the pause button lives on this
		# layer, so hiding it would leave the player no way to open the pause menu.
		if not is_touchscreen_device:
			GamestateManager.touch_ui_override = not GamestateManager.touch_ui_override
			_apply_visibility()
		get_viewport().set_input_as_handled()
		return
	# A hidden pad must not keep grabbing touches.
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			var local_position : Vector2 = pad.make_input_local(event).position
			if local_position.length() <= radius * grab_margin:
				touch_index = event.index
				update_joystick(local_position)
				get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == touch_index:
			release_joystick()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == touch_index:
		update_joystick(pad.make_input_local(event).position)
		get_viewport().set_input_as_handled()

func update_joystick(local_position: Vector2) -> void:
	var offset := local_position.limit_length(radius)
	nub.position = offset
	var direction := Vector2i.ZERO
	if offset.length() > radius * dead_zone:
		direction = Vector2i(Vector2.from_angle(snappedf(offset.angle(), PI / 4)).round())
	set_direction(direction)

func release_joystick() -> void:
	touch_index = -1
	if nub:
		nub.position = Vector2.ZERO
	set_direction(Vector2i.ZERO)

func set_direction(direction: Vector2i) -> void:
	set_action("move_left", direction.x < 0)
	set_action("move_right", direction.x > 0)
	set_action("move_up", direction.y < 0)
	set_action("move_down", direction.y > 0)

func set_action(action: StringName, pressed: bool) -> void:
	if pressed and not pressed_actions.get(action, false):
		Input.action_press(action)
		pressed_actions[action] = true
	elif not pressed and pressed_actions.get(action, false):
		Input.action_release(action)
		pressed_actions[action] = false
