extends Node2D

const finishline = preload("res://images/finishline.png")

var conversation = null
var current_item: int = 0
var used_choices: Dictionary[String, bool] = {}
var lap: int = 0
var total_laps: int = 2
var completed = false
var start_time = null

func init(completed_first_race: bool) -> void:
	if completed_first_race:
		$Hud/Timer.visible = true
	else:
		$Hud/Timer.visible = false
	load_conversation("millie")
	lap = 1
	update_lap()
	reset_conversation()
	$Hud.countdown()

func _process(_delta: float) -> void:
	if start_time:
		var elapsed = Time.get_ticks_msec() - start_time
		var minutes = elapsed / 60000
		var seconds = (elapsed / 1000) % 60
		var milliseconds = (elapsed % 1000) / 10
		$Hud/Timer.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	else:
		$Hud/Timer.text = "%02d:%02d.%02d" % [0, 0, 0]
		if $Hud.countdown_finished:
			start_time = Time.get_ticks_msec()
			advance_conversation(null)

func update_lap() -> void:
	get_node("Hud/Box/Lap").text = "Lap %s/%s" % [lap, total_laps]

func TheirLine() -> Node:
	return get_node("Conversation/Panel/MarginContainer/BoxContainer/HBoxContainer/TheirLine")

func YourLines() -> Node:
	return get_node("Conversation/Panel/MarginContainer/BoxContainer/YourLines")

func load_conversation(conversation_name: String) -> void:
	var data = FileAccess.get_file_as_string("res://scripts/script-%s.json" % conversation_name)
	var json = JSON.new()
	if json.parse(data) != OK:
		push_error("Failed to parse conversation JSON: ", json.get_error_message())
	conversation = json.data

func jump_to_marker(marker) -> bool:
	for i in range(len(conversation)):
		var item = conversation[i]
		if item.has("marker") and item["marker"] == marker:
			current_item = i + 1
			return true
	return false

func next_conversation_item():
	var i = current_item + 1
	while i < len(conversation) and conversation[i].has("marker"):
		i += 1
	if i < len(conversation):
		return conversation[i]
	else:
		return null

func reset_conversation() -> void:
	current_item = -1
	used_choices = {}
	completed = false
	start_time = null
	TheirLine().text = ""
	clear_buttons()
	if lap > 1:
		$Hud.show_item_block()

func advance_conversation(marker) -> void:
	if marker and marker != "FINISH":
		if not jump_to_marker(marker):
			push_error("Failed to jump to marker %s" % marker)
	else:
		current_item += 1
		if current_item >= len(conversation) or marker == "FINISH":
			if lap < total_laps:
				lap += 1
				update_lap()
				reset_conversation()
				advance_conversation(null)
			else:
				completed = true
			return
		while conversation[current_item].has("marker"):
			current_item += 1

	var item = conversation[current_item]
	var next_item = next_conversation_item()
	clear_buttons()
	if item.has("them"):
		TheirLine().text = item["them"]["line"]
		if item["them"]["emote"]:
			var opp = $Opponent/Sprite
			match item["them"]["emote"]:
				"neutral":
					opp.animation = "default"
				"anger":
					opp.animation = "anger"
				"love":
					opp.animation = "love"
				"sleep":
					opp.animation = "sleep"
				"surprise":
					opp.animation = "surprise"
				"uwu":
					opp.animation = "uwu"
		if item["them"]["next"]:
			add_button("...", item["them"]["next"], null)
		elif next_item:
			if next_item.has("them"):
				add_button("...", item["them"]["next"], null)
			elif next_item.has("you"):
				advance_conversation(null)
			elif next_item.has("end"):
				add_button("(finishline)", "FINISH", null)
			else:
				push_error("next_item had neither 'them', 'you', or 'end': %s" % item)
		else:
			add_button("(finishline)", "FINISH", null)
	elif item.has("you"):
		for choice in item["you"]:
			add_button(choice["line"], choice["next"], choice["id"])
	else:
		push_error("item had neither 'them' or 'you': %s" % item)

func clear_buttons():
	for child in YourLines().get_children():
		YourLines().remove_child(child)

func add_button(text, next, choice_id):
	var button = Button.new()
	button.clip_text = true
	if text == "(finishline)":
		button.icon = finishline
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		button.text = text
	if choice_id:
		button.disabled = used_choices.has(choice_id)
	var callback = func your_line_button_callback():
		if choice_id:
			used_choices[choice_id] = true
		advance_conversation(next)
	button.pressed.connect(callback)
	YourLines().add_child(button)
