extends Control

# -----------------------
# CONFIG (minimal)
# -----------------------
const LANES: Array[String] = ["←", "↓", "↑", "→"]   # 0,1,2,3
const KEY_MAP := {
	"ui_left":  0,
	"ui_down":  1,
	"ui_up":    2,
	"ui_right": 3
}

@export var VISIBLE_COUNT: int = 5
@export var SEQ_LENGTH: int = 10

const X_SPACING: float = 120.0
const ROW_SPACING: float = 60.0
const BUTTONS_Y_FRACTION: float = 0.78
const GAP_ABOVE_BUTTONS: float = 40.0

# -----------------------
# STATE
# -----------------------
var sequence: Array[int] = []          # remaining arrows (lane indices)
var visible_labels: Array[Label] = []  # exactly VISIBLE_COUNT labels reused
var bottom_labels: Array[Label] = []   # static lane labels

var _x_start: float = 0.0
var _top_y: float = 0.0
var _buttons_y: float = 0.0

var _rng := RandomNumberGenerator.new()
var _game_over: bool = false


func _ready() -> void:
	_rng.randomize()
	_create_bottom_labels()
	_create_visible_labels()
	_generate_sequence()
	_compute_layout()
	_refresh_visible_arrows()


# -----------------------
# LAYOUT (fixed, no resize handling)
# -----------------------
func _compute_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var group_width: float = float(LANES.size() - 1) * X_SPACING
	_x_start = vp.x * 0.5 - group_width * 0.5

	_buttons_y = vp.y * BUTTONS_Y_FRACTION
	_top_y = _buttons_y - GAP_ABOVE_BUTTONS - float(VISIBLE_COUNT - 1) * ROW_SPACING

	# position bottom (static) labels
	for i in range(LANES.size()):
		bottom_labels[i].position = Vector2(
			_x_start + float(i) * X_SPACING,
			_buttons_y
		)


# -----------------------
# SEQUENCE + LABELS
# -----------------------
func _generate_sequence() -> void:
	sequence.clear()
	for i in range(SEQ_LENGTH):
		sequence.append(_rng.randi_range(0, LANES.size() - 1))
	# Debug: print current sequence
	# print("SEQ:", [LANES[v] for v in sequence])


func _create_visible_labels() -> void:
	for i in range(VISIBLE_COUNT):
		var lbl := Label.new()
		add_child(lbl)
		visible_labels.append(lbl)


func _create_bottom_labels() -> void:
	for i in range(LANES.size()):
		var lbl := Label.new()
		lbl.text = LANES[i]
		add_child(lbl)
		bottom_labels.append(lbl)


func _refresh_visible_arrows() -> void:
	# show up to VISIBLE_COUNT from the start of 'sequence'
	var show_count: int = min(VISIBLE_COUNT, sequence.size())
	var start_row: int = VISIBLE_COUNT - show_count  # pack downwards

	for i in range(VISIBLE_COUNT):
		var lbl: Label = visible_labels[i]
		if i < show_count:
			var lane_index: int = sequence[i]
			lbl.text = LANES[lane_index]
			lbl.position = Vector2(
				_x_start + float(lane_index) * X_SPACING,
				_top_y + float(start_row + i) * ROW_SPACING
			)
			lbl.show()
		else:
			lbl.hide()


# -----------------------
# INPUT
# -----------------------
func _input(event: InputEvent) -> void:
	if _game_over:
		return
	if not event.is_pressed():
		return

	for action in KEY_MAP.keys():
		if event.is_action_pressed(action):
			_check_lane(KEY_MAP[action])


func _check_lane(lane_index: int) -> void:
	if sequence.is_empty():
		return

	var bottom_idx: int = int(min(VISIBLE_COUNT, sequence.size())) - 1
	var expected_lane: int = sequence[bottom_idx]

	if lane_index == expected_lane:
		_handle_correct(bottom_idx)
	else:
		_handle_wrong()


func _handle_correct(bottom_idx: int) -> void:
	# remove the bottom visible element
	sequence.remove_at(bottom_idx)

	if sequence.is_empty():
		_game_over = true
		print("nice")  # success
		_refresh_visible_arrows()  # hides all
		return

	_refresh_visible_arrows()


func _handle_wrong() -> void:
	_game_over = true
	print("wrong button")
