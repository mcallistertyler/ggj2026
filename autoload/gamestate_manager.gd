extends Node

signal pause_opened
signal pause_closed

# Based on the device type rather than touchscreen support, so touchscreen laptops
# still get keyboard controls.
var is_mobile_device : bool = DeviceInfo.is_mobile_platform()

# Desktop-only override flipped by the toggle_touch_controls action. Lives here rather
# than on the touch CanvasLayer because that node is instanced into every scene and is
# therefore recreated on each scene change, which used to drop the player's choice.
var touch_ui_override : bool = false

var hold_skip_time : float = 2.0

#Contains all LOCATIONS
#Just set to true by default if we skip the scene
var is_dialogue_exhausted: Dictionary = {
	"gate": false,
	"narvesen": false,
	"hallway": false,
	"kompis_hus": false,
	"gym": false,
	"eplehuset": false,
}


func exhaust_dialogue(dialogue_id: String):
	if dialogue_id in is_dialogue_exhausted.keys():
		if is_dialogue_exhausted[dialogue_id]:
			push_error("Someone tried to exhaust the same dialogue twice")
		is_dialogue_exhausted[dialogue_id] = true
	else:
		push_error("Tried to exhaust a dialogue that does not exist in GamestateManager: ", dialogue_id)

func has_won():
	return not is_dialogue_exhausted.values().has(false)
