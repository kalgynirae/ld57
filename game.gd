extends Node2D

var mode = 0

func _ready():
	$TitleScreen/Start.pressed.connect(advance_mode)
	$CharacterScreen/Proceed.pressed.connect(advance_mode)
	$OpponentScreen/Proceed.pressed.connect(advance_mode)
	$TrackScreen/Proceed.pressed.connect(advance_mode)

func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
	if $RaceScreen.completed:
		$RaceScreen.completed = false
		advance_mode()

func apply_mode():
	for child in get_children():
		child.visible = false
	if mode == 0:
		$TitleScreen.visible = true
	elif mode == 1:
		$CharacterScreen.visible = true
	elif mode == 2:
		$OpponentScreen.visible = true
	elif mode == 3:
		$TrackScreen.visible = true
	elif mode == 4:
		var race = $RaceScreen
		race.init()
		race.visible = true

func advance_mode():
	mode = (mode + 1) % 5
	apply_mode()
