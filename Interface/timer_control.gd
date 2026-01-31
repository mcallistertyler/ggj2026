extends CanvasLayer

signal timed_out

@onready var timer_text : RichTextLabel = get_node("%TimerText")
#TODO: I don't care about the progress bar yet
@onready var progress_bar : ProgressBar = get_node("%ProgressBar")

var timer_active : bool = false

func _ready() -> void:
	print("huh")
	self.hide()
	TimerManager.start_dialogue_timer.connect(_on_start_dialogue_timer)
	TimerManager.timer_manager_timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
	if timer_active:
		var time_left = TimerManager.get_time_left()
		timer_text.text = "%.2f" % time_left

func _on_start_dialogue_timer() -> void:
	print("Starting timer for response")
	timer_active = true
	self.show()

func _on_timer_timeout(_context: TimerManager.Context) -> void:
	timer_active = false
	self.hide()
