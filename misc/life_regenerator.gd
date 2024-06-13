extends Node2D

@export var regeneration_amount = 20

func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body:Node2D) -> void:
	if body.name == "Player":
		var player: Player = body;
		player.heal(regeneration_amount)
		queue_free()
