extends Node2D

var mode = 0
var completed_first_race = false

func _ready():
	$TitleScreen/Start.pressed.connect(advance_mode)
	$CharacterScreen/Proceed.pressed.connect(advance_mode)
	$OpponentScreen/Proceed.pressed.connect(advance_mode)
	$TrackScreen/Proceed.pressed.connect(advance_mode)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($TitleScreen/Title, "position", Vector2(0, 0), 0.6)
	tween.tween_property($TitleScreen/Subtitle, "position", Vector2(568, 547), 5)

func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
	if $RaceScreen.completed:
		$RaceScreen.completed = false
		completed_first_race = true
		advance_mode()

func advance_mode():
	mode = (mode + 1) % 5

	if mode == 0:
		$MusicTitleIntro.play()
		position = Vector2(0, 0)
	else:
		$MusicTitleLoop.stop()
		$MusicTitleIntro.stop()
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		# Fade to black for entering race scene
		if mode == 4:
			tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 0.6)
		tween.tween_property(self, "position", Vector2(0, -720 * mode), 0.6)
		if mode == 4:
			tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.6)
		tween.finished.connect(_on_transition_finished)

	if mode == 4:
		$RaceScreen.init(completed_first_race, "millie")

func _on_transition_finished() -> void:
	if mode == 4:
		$RaceScreen.begin()
	
func _on_music_title_intro_finished() -> void:
	$MusicTitleLoop.play()
