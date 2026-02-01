extends Control

class_name DabUpMinigame

enum DabUpCompletion { PASS_EASY, PASS_HARD, FAILURE }

signal dab_up_completed(score: int, dab_up_completion: DabUpCompletion, second_round: bool)

# DIFFICULTY SETTINGS
@export var SEQ_LENGTH: int = 10
@export var TIME_LIMIT: int = 10

@export var easy_score : int = 50
@export var hard_score : int = 100
@export var failure_score : int = -100

@export var dab_up_second_round : bool = false

var chosen_difficulty : Enums.ResponseTag

# -----------------------
# BUTTONS
# -----------------------
const LANES: Array[String] = ["←", "↑", "↓", "→"]   # indices: 0,1,2,3
const KEY_MAP := {
	"ui_left":  0,
	"move_left": 0,
	"ui_up":    1,
	"move_up": 1,
	"ui_down":  2,
	"move_down": 2,
	"ui_right": 3,
	"move_right": 3,
}

# STYLING CODE FOR BUTTONS
const X_SPACING: float = 120.0
const ROW_SPACING: float = 80.0
const BUTTONS_Y_FRACTION: float = 0.78
const GAP_ABOVE_BUTTONS: float = 80.0

# -----------------------
# STATE
# -----------------------
var sequence: Array[int] = []
var arrow_labels: Array[TextureRect] = []   # falling icons
var bottom_labels: Array[TextureRect] = []  # bottom row icons

var _x_start: float = 0.0
var _buttons_y: float = 0.0

var _rng := RandomNumberGenerator.new()
var _game_over: bool = false
var _input_allowed: bool = false
var _glow_tween: Tween = null

# -----------------------
# TEXTURES
# -----------------------
# Falling arrows (per lane)
@export var arrow_left:  Texture2D
@export var arrow_down:  Texture2D
@export var arrow_up:    Texture2D
@export var arrow_right: Texture2D

# Bottom row icons (per lane)
@export var arrow_left_label:  Texture2D
@export var arrow_down_label:  Texture2D
@export var arrow_up_label:    Texture2D
@export var arrow_right_label: Texture2D

# Built at runtime
var _lane_textures: Array[Texture2D] = []
var _bottom_lane_textures: Array[Texture2D] = []


func _ready():
	visible = false
	_rng.randomize()

	# Build lane -> texture map (falling arrows)
	_lane_textures = [arrow_left, arrow_up, arrow_down, arrow_right]
	for i in range(_lane_textures.size()):
		if _lane_textures[i] == null:
			push_warning("Missing texture for falling lane %d. Assign arrow_* textures in Inspector." % i)

	# Build bottom lane -> texture map (bottom static row)
	_bottom_lane_textures = [arrow_left_label, arrow_up_label, arrow_down_label, arrow_right_label]
	for i in range(_bottom_lane_textures.size()):
		if _bottom_lane_textures[i] == null:
			push_warning("Missing texture for bottom lane %d (arrow_*_label)." % i)

	_create_bottom_labels()
	_generate_sequence()
	_compute_layout()
	_rebuild_arrow_labels()

	TimerManager.timer_manager_timeout.connect(_on_timer_manager_timeout)

func _on_timer_manager_timeout(context: TimerManager.Context) -> void:
	if context == TimerManager.Context.MINIGAME:
		_failure()

func _compute_layout():
	var vp: Vector2 = get_viewport_rect().size
	var group_width: float = float(LANES.size() - 1) * X_SPACING
	_x_start = vp.x * 0.5 - group_width * 0.5

	_buttons_y = vp.y * BUTTONS_Y_FRACTION

	# position bottom (static) icons
	for i in range(LANES.size()):
		bottom_labels[i].position = Vector2(
			_x_start + float(i) * X_SPACING,
			_buttons_y
		)


# -----------------------
# SEQUENCE + LABELS
# -----------------------
func _generate_sequence():
	sequence.clear()
	for i in range(SEQ_LENGTH):
		sequence.append(_rng.randi_range(0, LANES.size() - 1))
	# Debug:
	# print("SEQ:", [LANES[v] for v in sequence])


func _create_bottom_labels():
	for i in range(LANES.size()):
		var tr := TextureRect.new()
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var tex: Texture2D = null
		if i >= 0 and i < _bottom_lane_textures.size():
			tex = _bottom_lane_textures[i]
		tr.texture = tex

		# --- ICON SIZES ---
		tr.custom_minimum_size = Vector2(70, 70)
		tr.size = tr.custom_minimum_size
		tr.modulate.a = 0.0  # Start invisible for tween

		add_child(tr)
		bottom_labels.append(tr)


func _clear_arrow_labels():
	for n in arrow_labels:
		if is_instance_valid(n):
			n.queue_free()
	arrow_labels.clear()


# Create one TextureRect for a given lane index using the exported textures
func _make_arrow_icon(lane_index: int) -> TextureRect:
	var tr := TextureRect.new()
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var tex: Texture2D = null
	if lane_index >= 0 and lane_index < _lane_textures.size():
		tex = _lane_textures[lane_index]
	tr.texture = tex

	# --- ICON SIZE ---
	tr.custom_minimum_size = Vector2(70, 70)
	tr.size = tr.custom_minimum_size
	# Start invisible only during intro, visible during gameplay
	tr.modulate.a = 1.0 if _input_allowed else 0.0

	return tr


func _rebuild_arrow_labels():
	# Clear and recreate icons to exactly match 'sequence'
	_clear_arrow_labels()

	# Compute top so that the last (bottom) arrow sits just above the buttons line
	var count := sequence.size()
	var top_y: float = _buttons_y - GAP_ABOVE_BUTTONS - float(max(0, count - 1)) * ROW_SPACING

	for i in range(count):
		var lane_index: int = sequence[i]

		# Use TextureRect instead of Label
		var icon := _make_arrow_icon(lane_index)
		icon.position = Vector2(
			_x_start + float(lane_index) * X_SPACING,
			top_y + float(i) * ROW_SPACING
		)
		add_child(icon)
		arrow_labels.append(icon)

	_highlight_active_arrow()


func _highlight_active_arrow():
	# Stop any existing glow tween
	if _glow_tween and _glow_tween.is_valid():
		_glow_tween.kill()

	if arrow_labels.is_empty():
		return

	# Only highlight during gameplay, not during intro
	if not _input_allowed:
		return

	# The bottom arrow (last in array) is the one to press
	var active_arrow := arrow_labels[arrow_labels.size() - 1]

	# Subtle pulsing glow effect
	_glow_tween = create_tween()
	_glow_tween.set_loops()
	_glow_tween.tween_property(active_arrow, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.4)
	_glow_tween.tween_property(active_arrow, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)


# -----------------------
# INPUT
# -----------------------
func _input(event: InputEvent):
	if self.visible == false:
		return
	if not _input_allowed:
		return
	if _game_over:
		return
	if not event.is_pressed():
		return

	for action in KEY_MAP.keys():
		if event.is_action_pressed(action):
			_on_lane_pressed(KEY_MAP[action])


func _on_lane_pressed(lane_index: int):
	if sequence.is_empty():
		return  # nothing to do

	# The bottom visible arrow is always the last element
	var bottom_idx: int = sequence.size() - 1
	var expected_lane: int = sequence[bottom_idx]

	if lane_index == expected_lane:
		# Correct: remove bottom arrow
		sequence.remove_at(bottom_idx)
		if sequence.is_empty():
			_game_over = true
			_success()
			_rebuild_arrow_labels()  # clears all
			return
		_rebuild_arrow_labels()
	else:
		# FAIL - timeout or wrong button
		_game_over = true
		_failure()


func _success():
	var chosen_score : int
	var chosen_completion : DabUpCompletion
	if chosen_difficulty == Enums.ResponseTag.HARD_MODE:
		chosen_score = hard_score
		chosen_completion = DabUpCompletion.PASS_HARD
	elif chosen_difficulty == Enums.ResponseTag.EASY_MODE:
		chosen_completion = DabUpCompletion.PASS_EASY
		chosen_score = easy_score
	self.dab_up_completed.emit(chosen_score, chosen_completion, dab_up_second_round)
	close()

func _failure():
	self.dab_up_completed.emit(failure_score, DabUpCompletion.FAILURE, dab_up_second_round)
	close()

signal popup_closed

# TODO: default closed, open with triggers from parent
func open(difficulty: Enums.ResponseTag):
	PlayerManager.player_movement.emit(false)
	chosen_difficulty = difficulty
	if chosen_difficulty == Enums.ResponseTag.HARD_MODE:
		TIME_LIMIT = 5
		SEQ_LENGTH = 10
	else:
		TIME_LIMIT = 10
		SEQ_LENGTH = 10

	# Start invisible for fade-in
	modulate.a = 0.0
	_input_allowed = false

	# Make visible and bring in front
	visible = true
	move_to_front()
	grab_focus()

	# Run intro tween sequence
	await _play_intro_tween()

	# Now start the timer and allow input
	TimerManager.create_dialogue_timer(float(TIME_LIMIT), TimerManager.Context.MINIGAME)
	_input_allowed = true
	_highlight_active_arrow()


func _play_intro_tween() -> void:
	var tween := create_tween()

	# Fade in the whole scene
	tween.tween_property(self, "modulate:a", 1.0, 0.15)

	# Fade in bottom labels together
	for label in bottom_labels:
		tween.parallel().tween_property(label, "modulate:a", 1.0, 0.12)

	await tween.finished

	# Fade in arrows sequentially (quick stagger)
	var arrow_tween := create_tween()
	for i in range(arrow_labels.size()):
		if i == 0:
			arrow_tween.tween_property(arrow_labels[i], "modulate:a", 1.0, 0.08)
		else:
			arrow_tween.parallel().tween_property(arrow_labels[i], "modulate:a", 1.0, 0.08).set_delay(i * 0.03)

	await arrow_tween.finished

func close() -> void:
	TimerManager.cancel_timer()
	_input_allowed = false
	if _glow_tween and _glow_tween.is_valid():
		_glow_tween.kill()

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished

	emit_signal("popup_closed")
	queue_free()
