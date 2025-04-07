extends Node2D

@export var button_group: ButtonGroup
var selected_date = null

func _ready():
	for button in button_group.get_buttons():
		button.pressed.connect(button_pressed)
		
func button_pressed():
	var pressed_button = button_group.get_pressed_button()
	if pressed_button == $MillieButton:
		$Proceed.disabled = false
		$Proceed.tooltip_text = ""
		selected_date = "millie"
	elif pressed_button == $WaspieButton:
		$Proceed.disabled = false
		$Proceed.tooltip_text = ""
		selected_date = "waspie"
	else:
		$Proceed.disabled = true
		$Proceed.tooltip_text = "You have not unlocked this date yet!"
