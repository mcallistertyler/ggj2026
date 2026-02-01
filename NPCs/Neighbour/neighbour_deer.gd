extends NPC

@onready var animated_sprite_3d : AnimatedSprite3D = get_node("%AnimatedSprite3D")

var first_anim_played : bool = false
# Show frame 1 when dialogue starts
# Go back to frame 0 when successful dialogue...or maybe whenever

func _ready() -> void:
	super._ready()
	DialogueManager.dialogue_started.connect(_on_neighbour_dialogue_started)

func _on_neighbour_dialogue_started(resource: DialogueResource) -> void:
	if self.dialogue.dialogue_resource == resource and !first_anim_played:
		first_anim_played = true
		animated_sprite_3d.frame = 1

func _on_minigame_completed(score: int, result: DabUpMinigame.DabUpCompletion, second_round: bool) -> void:
	super._on_minigame_completed(score, result, second_round)
	if result == DabUpMinigame.DabUpCompletion.PASS_EASY or result == DabUpMinigame.DabUpCompletion.PASS_HARD:
		animated_sprite_3d.frame = 0
