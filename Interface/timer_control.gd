extends Control

signal timed_out

@export var timeout_value : float
@onready var timer_text : RichTextLabel
@onready var progress_bar : ProgressBar

func _ready() -> void:
	self.hide()
	TimerManager.start_dialogue_timer.connect(_on_start_dialogue_timer)
	### TEST CODE
	#await get_tree().create_timer(2.0).timeout
	#print("creating some kind of dialogue")
	#DialogueTimerManager.start_dialogue_timer.emit()

func _on_start_dialogue_timer() -> void:
	print("should have showed?")
	self.show()


func start_timer() -> void:
	timer_text.text = ""
	
