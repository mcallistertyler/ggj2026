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

var is_touchscreen_device : bool = DisplayServer.is_touchscreen_available()
var touch_index : int = -1
var pressed_actions : Dictionary[StringName, bool] = {}

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	GamestateManager.pause_opened.connect(_on_pause_opened)
	GamestateManager.pause_closed.connect(_on_pause_closed)
	visible = always_visible or is_touchscreen_device
	set_process_input(visible)

func _on_pause_opened() -> void:
	if is_touchscreen_device:
		self.visible = false

func _on_pause_closed() -> void:
	if is_touchscreen_device:
		self.visible = true

func _on_dialogue_started(_resource) -> void:
	if is_touchscreen_device:
		self.visible = false

func _on_dialogue_ended(_resource) -> void:
	if is_touchscreen_device:
		self.visible = true

func _exit_tree() -> void:
	release_joystick()

func _input(event: InputEvent) -> void:
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
