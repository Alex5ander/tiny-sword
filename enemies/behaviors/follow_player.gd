extends Node

@export var speed = 20.0

var sprite: AnimatedSprite2D
var enemy: Enemy

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta):
	var player_positon = GameManager.player_position
	var direction = (player_positon - enemy.position).normalized()
	enemy.velocity = direction * speed
	sprite.flip_h = direction.x < 0
	enemy.move_and_slide()
