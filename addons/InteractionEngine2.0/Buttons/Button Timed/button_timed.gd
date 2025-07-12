extends Area3D
class_name button_timed

signal Pressed
signal Depressed

@export_group("Standard")
@export_range(-1,1000,1) var use_amount : int = -1
@export var _active : bool = true
@export_range(-1,1000,0.1) var Pop_out_delay : float = 5.0
@export_group("Text")
@export var Display_mode : bool = false
@export_multiline var Enter_text : String = ""
@export_multiline var Description_text : String = ""
@export_range(0,100,0.1) var Description_text_fade_time : float = 5.0

@onready var display_label = $DisplayLabel
@onready var description_label = $DescriptionLabel


var button_pressed : bool = false
var inside : bool = false

func _ready():
	area_entered.connect(entered)
	area_exited.connect(exited)
	display_label.hide()
	description_label.hide()
	
	display_label.text = Enter_text
	description_label.text = Description_text

func _physics_process(delta):
	if _active:
		monitoring = true
	else:
		monitoring = false

func entered(_body):
	inside = true
	display_text()

func exited(_body):
	inside = false
	display_text()

func pressed():
	if !button_pressed:
		if Pop_out_delay == -1:
			Pressed.emit()
			button_pressed = true
			Depressed.emit()
			button_pressed = false
		elif !Display_mode:
			Pressed.emit()
			button_pressed = true
			await get_tree().create_timer(Pop_out_delay).timeout
			Depressed.emit()
			button_pressed = false
		else:
			Pressed.emit()
			button_pressed = true
			display_label.hide()
			description_label.modulate.a = 1
			description_label.show()
			var fade_tween = get_tree().create_tween()
			fade_tween.tween_property(description_label, "modulate:a", 0, Description_text_fade_time)
			await get_tree().create_timer(Pop_out_delay).timeout
			description_label.hide()
			if inside:
				description_label.modulate.a = 1
				display_label.show()
			Depressed.emit()
			button_pressed = false
	
		if use_amount != -1:
			use_amount -= 1
		if use_amount == 0:
			queue_free()

func _input(event):
	if event.is_action_pressed("Interact"):
		if _active and inside:
			pressed()

func activate():
	_active = true

func deactivate():
	_active = false
	display_label.hide()

func display_text():
	if Display_mode:
		if inside:
			if !button_pressed:
				display_label.show()
			description_label.hide()
		else:
			display_label.hide()
