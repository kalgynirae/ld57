extends Node2D

const BODIES = ["wormbodypink.png", "wormbodyblue.png", "wormbodygreen.png", "wormbodygrey.png", "wormbodypurple.png", "wormbodyyellow.png"]
const EYES = ["wormeyesbeats.png", "wormeyescat.png", "wormeyeshappy.png", "wormeyesnerd.png", "wormeyessad.png", "wormeyesshock.png"]
const CLOTHES = ["wormclothesblacktee.png", "wormclothesbowtie.png", "wormclothesbra.png", "wormclothesscarf.png", "wormclothesvest.png"]

var selected_body = 0
var selected_eyes = 0 
var selected_clothes = 0

func _ready():
	$PrevBody.pressed.connect(decrement_body)
	$NextBody.pressed.connect(increment_body)
	$PrevEyes.pressed.connect(decrement_eyes)
	$NextEyes.pressed.connect(increment_eyes)
	$PrevClothes.pressed.connect(decrement_clothes)
	$NextClothes.pressed.connect(increment_clothes)
	
func decrement_body():
	selected_body = (selected_body - 1) % BODIES.size()
	update_preview()

func increment_body():
	selected_body = (selected_body + 1) % BODIES.size()
	update_preview()
	
func decrement_eyes():
	selected_eyes = (selected_eyes - 1) % EYES.size()
	update_preview()
	
func increment_eyes():
	selected_eyes = (selected_eyes + 1) % EYES.size()
	update_preview()
	
func decrement_clothes():
	selected_clothes = (selected_clothes - 1) % CLOTHES.size()
	update_preview()
	
func increment_clothes():
	selected_clothes = (selected_clothes + 1) % CLOTHES.size()
	update_preview()

func update_preview():
	var body_path = "res://images/" + BODIES[selected_body]
	var eyes_path = "res://images/" + EYES[selected_eyes]
	var clothes_path = "res://images/" + CLOTHES[selected_clothes]
	
	var body_texture = load(body_path)
	var eyes_texture = load(eyes_path)
	var clothes_texture = load(clothes_path)
	
	$SelectedBody.texture = body_texture
	$PreviewBody.texture = body_texture
	$SelectedEyes.texture = eyes_texture
	$PreviewEyes.texture = eyes_texture
	$SelectedClothes.texture = clothes_texture
	$PreviewClothes.texture = clothes_texture
	
	$PanelContainer/MarginContainer/BoxContainer/SpeedBar.value = randi_range(10, 90)
	$PanelContainer/MarginContainer/BoxContainer/AccelerationBar.value = randi_range(10, 90)
	$PanelContainer/MarginContainer/BoxContainer/WeightBar.value = randi_range(10, 90)
	$PanelContainer/MarginContainer/BoxContainer/HandlingBar.value = randi_range(10, 90)
	$PanelContainer/MarginContainer/BoxContainer/TractionBar.value = randi_range(10, 90)
