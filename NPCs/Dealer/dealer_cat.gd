extends NPC

@onready var animated_sprite_3d : AnimatedSprite3D = get_node("%AnimatedSprite3D")

var played_first_anim : bool = false

func _ready() -> void:
	super._ready()
	DialogueManager.dialogue_started.connect(_on_dealer_dialogue_started)

func _on_dealer_dialogue_started(resource: DialogueResource) -> void:
	if resource == self.dialogue.dialogue_resource and !played_first_anim:
		played_first_anim = true
		animated_sprite_3d.frame = 1

func _on_minigame_completed(score: int, result: DabUpMinigame.DabUpCompletion, second_round: bool) -> void:
	super._on_minigame_completed(score, result, second_round)
	if result == DabUpMinigame.DabUpCompletion.FAILURE:
		animated_sprite_3d.frame = 2
		await get_tree().create_timer(1.0).timeout
		animated_sprite_3d.frame = 0
