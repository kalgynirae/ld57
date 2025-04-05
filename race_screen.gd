extends Node2D

var current_stage: StringName = &"start"
var current_line: int = 0
var used_choices: Dictionary[StringName, bool] = {}
var lap: int = 0
var total_laps: int = 3

func init() -> void:
	lap = 1
	update_lap()

func update_lap() -> void:
	get_node("Hud/Box/Lap").text = "Lap %s/%s" % [lap, total_laps]

func their_line() -> void:
	return get_node("Conversation/Panel/MarginContainer/BoxContainer/TheirLine")

func your_lines() -> void:
	return get_node("Conversation/Panel/MarginContainer/BoxContainer/YourLines")

func advance_conversation() -> void:
	pass

const conversation = {
	&"start": {
		"them": [
			"Hello! It's nice to finally meet you.",
		],
		"you": [
			["And also with you.", &"1"],
			["Technically, we haven't met yet.", &"2"],
		],
	},
	&"1": {
		"them": ["*bows profusely*"],
		"you": [
			["Yep", &"3"],
		],
	},
	&"2": {
		"them": [
			"...",
			".....",
			"................",
		],
		"you": [
			["Yep", &"3"],
		],
	},
	&"3": {
		"them": [
			"How do you feel about the economy?",
		],
		"you": [],
	},
}
