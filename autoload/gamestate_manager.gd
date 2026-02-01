extends Node


#Contains all LOCATIONS
#Just set to true by default if we skip the scene
var is_dialogue_exhausted: Dictionary = {
	"gate": false,
	"narvesen": false,
	"hallway": false,
	"leilighet": false,
	"kompis_hus": false,
	"gym": false,
	"eplehuset": false,
}


func exhaust_dialogue(dialogue_id: String):
	if dialogue_id in is_dialogue_exhausted.keys:
		if is_dialogue_exhausted[dialogue_id]:
			push_error("Someone tried to exhaust the same dialogue twice")
		is_dialogue_exhausted[dialogue_id] = true
	else:
		push_error("Tried to exhaust a dialogue that does not exist in GamestateManager: ", dialogue_id)

func has_won():
	return not is_dialogue_exhausted.values().has(false)
