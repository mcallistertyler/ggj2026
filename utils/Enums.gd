extends RefCounted

class_name Enums

# You might need to reload the Godot project to get these to show up when creating a new SceneEntry
# ...kind of annoying but that's how it be.
enum Scenes { WORLD_MAP, NARVESEN, KOMPIS_HUS, GYM, GATE, GANGEN, HJEMME_LEILIGHET, EPLEHUS, MAIN_MENU, ENDING }

# Possible responses that come back from dialogue
enum ResponseTag { NONE, EASY_MODE, HARD_MODE, FAILURE }

const RESPONSE_TAG_MAP : Dictionary[String, ResponseTag] = {
	"easy_mode": ResponseTag.EASY_MODE,
	"hard_mode": ResponseTag.HARD_MODE,
	"failure": ResponseTag.FAILURE
}

static func get_dialogue_response_tag(response: DialogueResponse) -> ResponseTag:
	var response_tag = response.get_tag_value("response_type")
	if response_tag.is_empty():
		return ResponseTag.NONE
	if response_tag in RESPONSE_TAG_MAP:
		return RESPONSE_TAG_MAP[response_tag]
	return ResponseTag.NONE
