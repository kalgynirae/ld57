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

	adjust_music(mode)

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
	
	$RaceScreen.visible = false

	adjust_music(mode)

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	if mode == 0:
		position = Vector2(0, 0)
	elif mode < 4:
		var target_y = 0
		match mode:
			1:
				target_y = -$CharacterScreen.position.y
			2:
				target_y = -$OpponentScreen.position.y
			3:
				target_y = -$TrackScreen.position.y
		tween.tween_property(self, "position", Vector2(0, target_y), 0.75)
	elif mode == 4:
		# Fade to black for entering race scene
		tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 0.6)
		tween.tween_callback(_on_faded_to_black)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.6)
	
	tween.finished.connect(_on_transition_finished)

	if mode == 4:
		var selected_date = $OpponentScreen.selected_date
		var selected_track = $TrackScreen.selected_track
		$RaceScreen.init(completed_first_race, selected_date, selected_track)

func _on_faded_to_black() -> void:
	if mode == 4:
		$RaceScreen.visible = true

func _on_transition_finished() -> void:
	if mode == 4:
		$RaceScreen.begin()

func adjust_music(new_mode: int) -> void:
	match new_mode:
		0:
			var tween = get_tree().create_tween().set_parallel(true)
			tween.tween_property($MusicTitleIntro, "volume_linear", 0.9, 1.0)
			tween.tween_property($MusicTitleLoop, "volume_linear", 0.9, 1.0)
			tween.tween_property($MusicMenusIntro, "volume_linear", 0.0, 1.0)
			tween.tween_property($MusicMenusLoop, "volume_linear", 0.0, 1.0)
		1:
			var tween = get_tree().create_tween().set_parallel(true)
			tween.tween_property($MusicTitleIntro, "volume_linear", 0.0, 1.0)
			tween.tween_property($MusicTitleLoop, "volume_linear", 0.0, 1.0)
			tween.tween_property($MusicMenusIntro, "volume_linear", 0.9, 1.0)
			tween.tween_property($MusicMenusLoop, "volume_linear", 0.9, 1.0)
		4:
			var tween = get_tree().create_tween().set_parallel(true)
			tween.tween_property($MusicMenusIntro, "volume_linear", 0.0, 1.0)
			tween.tween_property($MusicMenusLoop, "volume_linear", 0.0, 1.0)
				
func _on_music_title_intro_finished() -> void:
	$MusicTitleLoop.play()
	$MusicMenusLoop.play()
