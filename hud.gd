extends Node2D

var countdown_state: int = 0
var countdown_finished: bool = false

func countdown() -> void:
	countdown_state = 0
	countdown_finished = false
	$Countdown.start()

func _on_countdown_timeout() -> void:
	match countdown_state:
		4: $Three.visible = true
		7: $Three.visible = false
		8: $Two.visible = true
		11: $Two.visible = false
		12: $One.visible = true
		15: $One.visible = false
		16:
			$Date.visible = true
			countdown_finished = true
		20:
			$Date.visible = false
			$Countdown.stop()
	countdown_state += 1
