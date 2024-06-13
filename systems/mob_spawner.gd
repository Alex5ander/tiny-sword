extends Node2D

@onready var path_follow_2d: PathFollow2D = %path_follow_2d
@export var creatures: Array[PackedScene]
var t = 0

func _ready():
	pass

func _process(delta):
	if Time.get_ticks_msec() - t > 1000:
		var creature = creatures.pick_random().instantiate()
		creature.position = get_point()
		get_parent().add_child(creature)
		t = Time.get_ticks_msec()

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
