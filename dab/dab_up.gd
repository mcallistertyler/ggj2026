extends Control

# -----------------------
# CONFIG (minimal)
# -----------------------
const LANES: Array[String] = ["←", "↓", "↑", "→"]   # indices: 0,1,2,3
const KEY_MAP := {
	"ui_left":  0,
	"ui_down":  1,
	"ui_up":    2,
	"ui_right": 3
}

# varies depending on difficulty
@export var SEQ_LENGTH: int = 10
@export var TIME_LIMIT: int = 10

const X_SPACING: float = 120.0
const ROW_SPACING: float = 60.0
const BUTTONS_Y_FRACTION: float = 0.78
const GAP_ABOVE_BUTTONS: float = 40.0

# -----------------------
# STATE
# -----------------------
var sequence: Array[int] = []
var arrow_labels: Array[Label] = []
var bottom_labels: Array[Label] = []

var _x_start: float = 0.0
var _buttons_y: float = 0.0

var _rng := RandomNumberGenerator.new()
var _game_over: bool = false

func _ready():
	_rng.randomize()
	_create_bottom_labels()
	_generate_sequence()
	_compute_layout()
	_rebuild_arrow_labels()

func _compute_layout():
	var vp: Vector2 = get_viewport_rect().size
	var group_width: float = float(LANES.size() - 1) * X_SPACING
	_x_start = vp.x * 0.5 - group_width * 0.5

	_buttons_y = vp.y * BUTTONS_Y_FRACTION

	# position bottom (static) labels
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
		var lbl := Label.new()
		lbl.text = LANES[i]
		add_child(lbl)
		bottom_labels.append(lbl)


func _clear_arrow_labels():
	for lbl in arrow_labels:
		if is_instance_valid(lbl):
			lbl.queue_free()
	arrow_labels.clear()


func _rebuild_arrow_labels():
	# Clear and recreate labels to exactly match 'sequence'
	_clear_arrow_labels()

	# Compute top so that the last (bottom) arrow sits just above the buttons line
	var count := sequence.size()
	var top_y: float = _buttons_y - GAP_ABOVE_BUTTONS - float(max(0, count - 1)) * ROW_SPACING

	for i in range(count):
		var lane_index: int = sequence[i]
		var lbl := Label.new()
		lbl.text = LANES[lane_index]
		lbl.position = Vector2(
			_x_start + float(lane_index) * X_SPACING,
			top_y + float(i) * ROW_SPACING
		)
		add_child(lbl)
		arrow_labels.append(lbl)


# -----------------------
# INPUT
# -----------------------
func _input(event: InputEvent):
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
	print("NICE")
	
func _failure():
	print("FAIL")
	
