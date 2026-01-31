extends Area3D

var is_player_within_area : bool = false
var has_player_entered_room : bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta):
	if is_player_within_area and Input.is_action_just_pressed("ui_accept"):
		SceneManager.transition_to_scene(Enums.Scenes.WORLD_MAP)

func _on_body_entered(body):
	is_player_within_area = true

func _on_body_exited(body):
	is_player_within_area = false
	has_player_entered_room = true
