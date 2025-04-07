extends Node2D

func init(lap_times: Array[int]) -> void:
	var lap_times_displays = []
	for i in range(lap_times.size()):
		lap_times_displays.append(getLapTimeDisplay(lap_times[i], i + 1))
	$PanelContainer/MarginContainer/BoxContainer/LapTimes.text = "\n".join(lap_times_displays)

func getLapTimeDisplay(elapsed: int, lap: int) -> String:
	var minutes = elapsed / 60000
	var seconds = (elapsed / 1000) % 60
	var milliseconds = (elapsed % 1000) / 10
	return "Lap %s: %02d:%02d.%02d" % [lap, minutes, seconds, milliseconds]
