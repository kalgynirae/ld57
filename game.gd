extends Node2D

var mode = 0
var completed_first_race = false

func _ready():
	$TitleScreen/Start.pressed.connect(advance_mode)
	$CharacterScreen/Proceed.pressed.connect(advance_mode)
	$OpponentScreen/Proceed.pressed.connect(advance_mode)
	$TrackScreen/Proceed.pressed.connect(advance_mode)
	$ResultsScreen/Proceed.pressed.connect(advance_mode)
	
func start():
	$ClickToStart.visible = false

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($TitleScreen/Title, "position", Vector2(0, 0), 0.6)
	tween.tween_property($TitleScreen/Subtitle, "position", Vector2(568, 547), 5)

	$MusicTitleIntro.play()
	$MusicMenusIntro.play()
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
	mode = (mode + 1) % 6

	adjust_music(mode)

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	if mode > 0 and mode < 4:
		tween.tween_property(self, "position", get_target_position(), 0.75)
	else:
		# Fade to black for entering race and results scenes
		tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 0.6)
		tween.tween_callback(_on_faded_to_black)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.6)
	
	tween.finished.connect(_on_transition_finished)

	if mode == 4:
		var selected_date = $OpponentScreen.selected_date
		var selected_track = $TrackScreen.selected_track
		$RaceScreen.init(
			completed_first_race,
			selected_date,
			selected_track,
			$CharacterScreen.CLOTHES_NAMES[$CharacterScreen.selected_clothes],
		)

func _on_faded_to_black() -> void:
	if mode < 4:
		position = get_target_position()
		$RaceScreen.visible = false
		$ResultsScreen.visible = false
	if mode == 4:
		$RaceScreen.visible = true
	if mode == 5:
		$ResultsScreen.init($RaceScreen.lap_times)
		$ResultsScreen.visible = true

func get_target_position() -> Vector2:
	var target_y = 0
	match mode:
		1:
			target_y = -$CharacterScreen.position.y
		2:
			target_y = -$OpponentScreen.position.y
		3, 4, 5:
			target_y = -$TrackScreen.position.y
	return Vector2(0, target_y)

func _on_transition_finished() -> void:
	if mode == 4:
		$RaceScreen.begin()

func adjust_music(new_mode: int) -> void:
	match new_mode:
		0:
			var tween = get_tree().create_tween().set_parallel(true)
			# If the intro is still playing, we can assume this is the first viewing
			# of the title screen and set it immediately to full volume.
			$MusicTitleIntro.volume_linear = 1.0
			tween.tween_property($MusicTitleLoop, "volume_linear", 0.9, 1.0)
			tween.tween_property($MusicMenusIntro, "volume_linear", 0.0, 1.0)
			tween.tween_property($MusicMenusLoop, "volume_linear", 0.0, 1.0)
		1, 5:
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

func _on_click_to_start_gui_input(event) -> void:
	if event is InputEventMouseButton:
		start()
