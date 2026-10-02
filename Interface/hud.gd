extends CanvasLayer

class_name HUD
const CREDZ_POPUP : PackedScene = preload("res://Interface/ScorePopup.tscn")

@export var skip_label : SkipLabel
@export var add_icon : Texture2D
@export var subtract_icon : Texture2D

@onready var credz_label = %CredzLabel
@onready var credz_readout : Control = $HBoxContainer
@onready var viewport_size := get_viewport().get_visible_rect().size

var popup_spawn_position = Vector2(500,500)
var _dialogue_active : bool = false

func _ready() -> void:
	if self.get_parent() is Intro:
		skip_label.is_intro = true
		skip_label.visible = true
	else:
		skip_label.is_intro = false
		skip_label.visible = false
	CredzManager.credz_decreased.connect(_on_credz_decreased)
	CredzManager.credz_increased.connect(_on_credz_increased)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	credz_readout.gui_input.connect(_on_credz_readout_gui_input)
	popup_spawn_position = Vector2(
		viewport_size.x - 20,
		viewport_size.y * 0.3
	)
	
	credz_label.text = str(CredzManager.credz)
	
# The credz readout doubles as a pause button, the same as the on-screen PAUSE button.
func _on_credz_readout_gui_input(event: InputEvent) -> void:
	# One physical click or tap reaches this twice, once as a mouse event and once as a
	# screen touch, because the project emulates touch from mouse and mouse from touch.
	# Listening for only the mouse event keeps this from firing twice, and emulation
	# still delivers that event on phones.
	if not event is InputEventMouseButton:
		return
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	# The balloon claims every unhandled event while a dialogue is showing, so a pause
	# raised from here would be dropped or land in the middle of a conversation.
	if _dialogue_active:
		return
	credz_readout.accept_event()
	# Same route the on-screen PAUSE button takes. Input.action_press() does not reach
	# _unhandled_input, so the action has to be fed back through the input pipeline.
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	Input.parse_input_event(cancel)

func _on_dialogue_started(_resource) -> void:
	_dialogue_active = true

func _on_dialogue_ended(_resource) -> void:
	_dialogue_active = false

func _on_credz_decreased(amount):
	credz_label.text = str(CredzManager.credz)

	var popup_instance = CREDZ_POPUP.instantiate()
	add_child(popup_instance)
	popup_instance.position = popup_spawn_position
	popup_instance.set_label(-abs(amount), subtract_icon)

func _on_credz_increased(amount):
	credz_label.text = str(CredzManager.credz)
	
	var popup_instance = CREDZ_POPUP.instantiate()
	add_child(popup_instance)
	popup_instance.position = popup_spawn_position
	popup_instance.set_label(amount, add_icon)
	
