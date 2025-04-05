extends Node2D

var mode = 0

func _ready():
	get_node("TitleScreen/Start").pressed.connect(advance_mode)
	get_node("CharacterScreen/Proceed").pressed.connect(advance_mode)
	get_node("OpponentScreen/Proceed").pressed.connect(advance_mode)
	get_node("TrackScreen/Proceed").pressed.connect(advance_mode)

func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()

func apply_mode():
	for child in get_children():
		child.visible = false
	if mode == 0:
		get_node("TitleScreen").visible = true
	elif mode == 1:
		get_node("CharacterScreen").visible = true
	elif mode == 2:
		get_node("OpponentScreen").visible = true
	elif mode == 3:
		get_node("TrackScreen").visible = true
	elif mode == 4:
		get_node("RaceScreen").visible = true

func advance_mode():
	mode += 1
	apply_mode()
