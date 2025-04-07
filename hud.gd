extends Node2D

var countdown_state: int = 0
var countdown_finished: bool = false

func _ready() -> void:
	hide_item_block()

func countdown() -> void:
	countdown_state = 0
	countdown_finished = false
	$Countdown.start()

func _on_countdown_timeout() -> void:
	match countdown_state:
		7:
			$Three.visible = true
			$CountdownAudio.play()
		10: $Three.visible = false
		11: $Two.visible = true
		14: $Two.visible = false
		15: $One.visible = true
		18: $One.visible = false
		19:
			$Date.visible = true
			countdown_finished = true
		23:
			$Date.visible = false
			$Countdown.stop()
	countdown_state += 1

var current_item = null
const items = ["banana", "shell", "star"]

func hide_item_block() -> void:
	$Item.visible = false

func show_item_block() -> void:
	$Item.visible = true
	$Item/Particles.emitting = false
	$Item/Banana.visible = false
	$Item/Shell.visible = false
	$Item/Star.visible = false
	$Item/ItemBox.visible = true

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if $Item.visible and $Item/ItemBox.visible:
			$Item/Particles.emitting = true
			current_item = items.pick_random()
			match current_item:
				"banana":
					$Item/Banana.visible = true
				"shell":
					$Item/Shell.visible = true
				"star":
					$Item/Star.visible = true
			$Item/ItemBox.visible = false
		elif current_item != null:
			# TODO: use the item
			pass
