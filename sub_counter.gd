tool
extends Control

var token: String = "AIzaSyA8bSuz3p2c-L7DMuf1eVomqHnGwHxO81M"
var channel_id: String = "UCdTlz5pCHBUivLIz9cfvWWw"
var max_results : int = 30


func _ready():
	$profile/main/button_container/close.connect("pressed", self, "_on_close_pressed")
	$profile/main/button_container/save.connect("pressed", self, "_on_save_pressed")
	reload()


func _on_close_pressed():
	$profile.hide()


func _on_save_pressed():
	$username_request.request("https://www.googleapis.com/youtube/v3/search?key=" + token + "&type=Channel&q=" + $profile/main/url_container/name_input.text.replace(" ", "_"))
	$profile.hide()


func reload():
	$sub_request.request("https://www.googleapis.com/youtube/v3/channels?part=statistics&id=" + channel_id + "&key=" + token)


func _on_sub_request_completed(_result, response_code, headers, body):
	var result : Dictionary = JSON.parse(body.get_string_from_utf8()).result
	if result.has("error"):
		$interface/sub_counter.text = "ERROR"
		printerr(result.error.message)
	elif result.has("items"):
		if result.items[0].statistics.hiddenSubscriberCount == true:
			$interface/sub_counter.text = "HIDDEN"
		else:
			update_counter(result.items[0].statistics.subscriberCount)
	else:
		$interface/sub_counter.text = "ERROR"
		printerr("Failed finding channel")


func update_counter(subs):
	var trios: int = round(len(subs) / 3.0)

	if trios > 1:
		for i in range(1, trios):
			subs.erase(len(subs) - 3, 3)

		if trios < 3:
			subs = subs + "K"
		else:
			subs = subs + "M"
	$interface/sub_counter.text = subs


func _on_settings_pressed():
	$profile.popup()


func _on_takelime_pressed():
	OS.shell_open("https://www.youtube.com/takelime")


func _on_username_request_completed(_result, response_code, headers, body):
	var result : Dictionary = JSON.parse(body.get_string_from_utf8()).result
	if result.items.empty():
		printerr("Failed finding channel")
		return
	else:
		channel_id = result.items[0].id.channelId
		reload()


func _on_reload_timeout():
	reload()
