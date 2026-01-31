extends Control

signal timed_out

@export var timeout_value : float
@onready var timer_text : RichTextLabel
@onready var progress_bar : ProgressBar

func start_timer() -> void:
	timer_text.text = ""
	
