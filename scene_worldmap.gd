extends Node2D

@export var scene_car : OverworldCar

func _ready() -> void:
	scene_car.movement_allowed = true

	AudioManager.play_music("hip_hop")
	AudioManager.create_audio_player(self, "engine-hum", -3.0)

	disable_exhausted_locations()
	check_win_conditions()

#You can use GamestateManager.exhaust_dialogue("id") to permanently disable a location in the map
func disable_exhausted_locations():
	if GamestateManager.is_dialogue_exhausted["gate"]:
		$EntryFoodStore.monitoring = false
		$EntryFoodStore.cross_off()
	if GamestateManager.is_dialogue_exhausted["narvesen"]:
		$EntryNarvesen.monitoring = false
		$EntryNarvesen.cross_off()
	if GamestateManager.is_dialogue_exhausted["hallway"]:
		$EntryHome.monitoring = false
		$EntryHome.cross_off()
	if GamestateManager.is_dialogue_exhausted["kompis_hus"]:
		$EntryHouseYellow.monitoring = false
		$EntryHouseYellow.cross_off()
	if GamestateManager.is_dialogue_exhausted["gym"]:
		$EntryGym.monitoring = false
		$EntryGym.cross_off()
	if GamestateManager.is_dialogue_exhausted["eplehuset"]:
		$EntryApple.monitoring = false
		$EntryApple.cross_off()
	
	#"gate",
	#"narvesen
	#"hallway"
	#"kompis_hus"
	#"gym"
	#"eplehuset"

func check_win_conditions():
	if GamestateManager.has_won():
		SceneManager.transition_to_scene(Enums.Scenes.ENDING)
