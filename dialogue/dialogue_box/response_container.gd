extends HBoxContainer
class_name ResponseContainer

var response: DialogueResponse:
	set(value):
		response = value
		_update_icon_and_text()
	get:
		return response

var text: String:
	set(value):
		var response_button = get_node_or_null("ResponseExample")
		response_button.text = value
	get:
		var response_button = get_node_or_null("ResponseExample")
		return response_button.text


func _update_icon_and_text() -> void:
	if response == null:
		return
	
	# Update the text
	text = response.text
	
	# Update the icon based on response difficulty
	var icon_rect = get_node_or_null("AnimatedTextureRect")
	if icon_rect == null:
		return
	
	var response_tag = Enums.get_dialogue_response_tag(response)
	match response_tag:
		Enums.ResponseTag.EASY_MODE:
			icon_rect.texture = preload("res://assets/ui/response_neutral.png")
		Enums.ResponseTag.HARD_MODE:
			icon_rect.texture = preload("res://assets/ui/response_cool.png")
	
