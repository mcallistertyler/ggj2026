extends CanvasLayer


@export var always_visible : bool = false

@export_range(0.0, 1.0) var dead_zone : float = 0.2

@export var grab_margin : float = 1.25

@export var interact_active_color : Color = Color.WHITE
@export var interact_glow_color : Color = Color(1, 1, 1, 0.6)
@export var interact_glow_period : float = 0.8
@export var interact_glow_size_min : int = 4
@export var interact_glow_size_max : int = 14

@onready var pad : Node2D = $Pad
@onready var base : Sprite2D = $Pad/Base
@onready var nub : Sprite2D = $Pad/Nub

@onready var interact_button : TouchScreenButton = get_node("%InteractButton")
@onready var pause_button : TouchScreenButton = get_node("%PauseButton")
@onready var interact_panel : Panel = interact_button.get_node("Panel")

@onready var radius : float = base.texture.get_width() / 2.0

var is_touchscreen_device : bool = DeviceInfo.is_touch_device()
var touch_index : int = -1
var blocked_by_ui : bool = false
var pressed_actions : Dictionary[StringName, bool] = {}

# Runtime override, flipped by the toggle_touch_controls action so the controls can be
# tested on desktop without editing the scene.
var _force_touch_ui : bool = false
var _pause_open : bool = false
var _dialogue_active : bool = false
var _interact_glow_tween : Tween
var _interact_panel_style : StyleBoxFlat
var _interact_idle_color : Color

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	GamestateManager.pause_opened.connect(_on_pause_opened)
	GamestateManager.pause_closed.connect(_on_pause_closed)
	PlayerManager.interact_available.connect(_on_interact_available)
	_interact_panel_style = interact_panel.get_theme_stylebox("panel").duplicate()
	interact_panel.add_theme_stylebox_override("panel", _interact_panel_style)
	_interact_idle_color = _interact_panel_style.bg_color
	# Input stays enabled even while hidden, otherwise the toggle key is never delivered.
	set_process_input(true)
	_apply_visibility()

func _apply_visibility() -> void:
	var wanted : bool = always_visible or is_touchscreen_device or _force_touch_ui
	var should_show : bool = wanted and not _pause_open and not _dialogue_active
	if should_show == visible:
		return
	visible = should_show
	if not visible:
		# Never leave move_* actions held when the pad disappears mid-drag.
		release_joystick()

func _on_interact_available(is_available: bool) -> void:
	if is_available:
		start_interact_glow()
	else:
		stop_interact_glow()

func start_interact_glow() -> void:
	if _interact_glow_tween and _interact_glow_tween.is_valid():
		return
	_interact_panel_style.bg_color = interact_active_color
	_interact_panel_style.shadow_color = interact_glow_color
	_interact_panel_style.shadow_size = interact_glow_size_min
	var half_period : float = interact_glow_period / 2.0
	_interact_glow_tween = create_tween().set_loops()
	_interact_glow_tween.tween_property(_interact_panel_style, "shadow_size", interact_glow_size_max, half_period).set_trans(Tween.TRANS_SINE)
	_interact_glow_tween.tween_property(_interact_panel_style, "shadow_size", interact_glow_size_min, half_period).set_trans(Tween.TRANS_SINE)

func stop_interact_glow() -> void:
	if _interact_glow_tween:
		_interact_glow_tween.kill()
		_interact_glow_tween = null
	_interact_panel_style.bg_color = _interact_idle_color
	_interact_panel_style.shadow_size = 0

func _on_pause_opened() -> void:
	_pause_open = true
	set_blocked_by_ui(true)
	_apply_visibility()

func _on_pause_closed() -> void:
	_pause_open = false
	_apply_visibility()
	set_blocked_by_ui(false)

func _on_dialogue_started(_resource) -> void:
	_dialogue_active = true
	_apply_visibility()
	set_blocked_by_ui(true)

func _on_dialogue_ended(_resource) -> void:
	_dialogue_active = false
	_apply_visibility()
	refresh_visibility()
	set_blocked_by_ui(false)

func refresh_visibility() -> void:
	visible = not blocked_by_ui and (always_visible or GamestateManager.is_mobile_device)
	set_process_input(visible)
	if not visible:
		release_joystick()

func set_blocked_by_ui(blocked: bool) -> void:
	blocked_by_ui = blocked
	refresh_visibility()

func _exit_tree() -> void:
	release_joystick()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_touch_controls"):
		_force_touch_ui = not _force_touch_ui
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
