extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("TODO EXIT")
	#SceneManager.transition_to_scene(target_scene)
