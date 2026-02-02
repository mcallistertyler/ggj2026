extends RichTextLabel

class_name SkipLabel
@onready var being_held : bool = false
@onready var time_until_invisible_timer : Timer = $SkipTimer

var is_intro : bool = false
var fill_tween: Tween
var pulse_tween: Tween
var disappear_tween: Tween
var base_text: String = ""
@export var fill_colour : Color

func _ready() -> void:
	base_text = text
	_start_pulse()

func _start_pulse() -> void:
	pulse_tween = get_tree().create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "modulate", Color(1,1,1,0.0), 1.2)
	pulse_tween.tween_property(self, "modulate", Color(1,1,1,1.0), 1.2)

func set_held(held: bool) -> void:
	if is_intro and !self.visible:
		self.visible = true
	if is_intro:
		being_held = held
		if fill_tween:
			fill_tween.kill()
		if pulse_tween:
			pulse_tween.kill()
		if disappear_tween:
			disappear_tween.kill()

		# Reset visibility and restart the disappear timer on any input
		modulate.a = 1.0
		time_until_invisible_timer.start()

		if held:
			modulate = Color(1,1,1,1)
			fill_tween = get_tree().create_tween()
			fill_tween.tween_method(_update_fill, 0.0, 1.0, GamestateManager.hold_skip_time)
		else:
			_update_fill(0.0)
			_start_pulse()

func _update_fill(ratio: float) -> void:
	var char_count = base_text.length()
	var filled = int(char_count * ratio)
	if filled > 0:
		text = "[color=#" + fill_colour.to_html() + "]" + base_text.left(filled) + "[/color]" + base_text.substr(filled)
	else:
		text = base_text

func _on_skip_timer_timeout() -> void:
	if pulse_tween:
		pulse_tween.kill()
	disappear_tween = get_tree().create_tween()
	disappear_tween.tween_property(self, "modulate:a", 0.0, 0.5)
