extends CanvasLayer

@export var label: Label
@export var timerUI:Timer

func _process(delta):
	label.text = "00:"+str(int(timerUI.time_left))
	
