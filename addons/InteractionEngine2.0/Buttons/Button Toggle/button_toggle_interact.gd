extends Area3D
class_name button_toggle

signal On
signal Off

@export_group("Standard")
@export_range(-1,1000,1) var Use_amount : int = -1
@export var _active : bool = true
@export var Pop_out_delay: float = -1
@export_group("Text")
@export var Display_mode : bool = false
@export_multiline var Display_text : String = ""

@onready var display_label = $DisplayLabel

var button_pressed : bool = false
var inside : bool = false
var being_pressed : bool = false

func _ready():
	area_entered.connect(entered)
	area_exited.connect(exited)
	display_label.hide()
	
	display_label.text = Display_text

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
	being_pressed = true
	if Pop_out_delay == -1:
		if button_pressed:
			button_pressed = false
			Off.emit()
		else:
			button_pressed = true
			On.emit()
	else:
		display_label.hide()
		if button_pressed:
			Off.emit()
			await get_tree().create_timer(Pop_out_delay).timeout
			button_pressed = false
		else:
			On.emit()
			await get_tree().create_timer(Pop_out_delay).timeout
			button_pressed = true
		
	
	if Use_amount != -1:
		Use_amount -= 1
	if Use_amount == 0:
		queue_free()
	
	being_pressed = false
	
	if inside:
		display_text()

func _input(event):
	if event.is_action_pressed("Interact"):
		if _active and inside and !being_pressed:
			pressed()

func activate():
	_active = true

func deactivate():
	_active = false
	display_label.hide()

func display_text():
	if Display_mode and !being_pressed:
		if inside:
			display_label.show()
		else:
			display_label.hide()
