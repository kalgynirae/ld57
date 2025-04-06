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
		position.y = 0
	if mode != 0:
		var target_y = -720 * 2 * mode
		position = position.lerp(Vector2(0, target_y), 0.05)

func advance_mode():
	mode = (mode + 1) % 5
	if mode == 4:
		$RaceScreen.init()
