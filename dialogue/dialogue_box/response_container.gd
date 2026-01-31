extends HBoxContainer
class_name ResponseContainer

var text: String:
	set(value):
		var response_button = get_node_or_null("ResponseExample")
		response_button.text = value
	get:
		var response_button = get_node_or_null("ResponseExample")
		return response_button.text
