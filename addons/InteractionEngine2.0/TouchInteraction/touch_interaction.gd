class_name touch_interact extends Area3D
#signals

signal Entered
signal Exited

#export values

@export var _active : bool = true

#//#
@export_group("Delay options")
@export var Delay_enter : bool = false
@export var Delay_exit : bool = false
@export_range(0, 1000, 0.1) var Delay_enter_time : float = 0
@export_range(0, 1000, 0.1) var Delay_exit_time : float = 0

#//#
@export_group("Destroy options")
@export var Destroy_on_touch: bool = false
@export var Destroy_on_leave: bool = false

#//#
@export_group("Text options")
@export var Display_mode : bool = false
@export_multiline var Display_text : String = ""
@export_range(-1, 1000, 0.1) var Display_text_fade_time : float

#onready variables
@onready var display_label = $DisplayLabel

#//////////////////////////////////////////////////////////#

func _ready():
	area_entered.connect(entered)
	area_exited.connect(exited)
	display_label.hide()
	
	display_label.text = Display_text

func _physics_process(_delta):
	if _active:
		monitoring = true
	else:
		monitoring = false

func entered(_body):
	if !Delay_enter:
		Entered.emit()
	if Display_mode:
		if Display_text_fade_time != -1:
			display_label.modulate.a = 0
			display_label.show()
			var fade_tween = get_tree().create_tween()
			fade_tween.tween_property(display_label, "modulate:a", 1.0, Display_text_fade_time)
		else:
			display_label.show()
	if Delay_enter:
		await get_tree().create_timer(Delay_enter_time).timeout
		Entered.emit()
	
	if Destroy_on_touch:
		queue_free()

func exited(_body):
	if !Delay_exit:
		Exited.emit()
	if Display_mode:
		if Display_text_fade_time != -1:
			var fade_tween = get_tree().create_tween()
			fade_tween.tween_property(display_label, "modulate:a", 0.0, Display_text_fade_time)
			await fade_tween.finished
			display_label.hide()
		else:
			display_label.hide()
	if Delay_exit:
		await get_tree().create_timer(Delay_exit_time).timeout
		Exited.emit()
	
	if Destroy_on_leave:
		queue_free()

func activate():
	_active = true

func deactivate():
	_active = false
	display_label.hide()
