class_name Player
extends CharacterBody2D


@export var gameOverLabel: Label 

@export_category("Movement")
@export var speed: float = 3000.0
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var sword_area:Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@export var sword_damage = 2
@export_category("Ritual")
@export var ritual_scene: PackedScene
var ritualT = 0
var t = 0


@export var max_health = 10
var health = 10
@export var death_prefab: PackedScene

var input_vector: Vector2 = Vector2.ZERO
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0

func _ready():
	t = Time.get_ticks_msec()
	health = max_health

func _process(delta: float) -> void:
	update_hitbox_detection()
	GameManager.player_position = position
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	was_running = is_running
	is_running = !input_vector.is_zero_approx()
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			was_running = true
	
	# Tocar animações
	if !is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
	
	# Girar sprite
	if !input_vector.is_zero_approx() && !is_attacking:
		sprite.flip_h = input_vector.x < 0
	
	# Ataque
	if Input.is_action_just_pressed("attack"):
		attack()
		
	if Time.get_ticks_msec() - ritualT > 5500:
		update_ritual()
		ritualT = Time.get_ticks_msec()

func _physics_process(delta: float) -> void:
	var target_velocity = input_vector * speed * delta
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func attack() -> void:
	if !is_attacking:
		if abs(velocity.x) > abs(velocity.y):
			animation_player.play("attack_side_1")
		elif velocity.y < 0:
			animation_player.play("attack_up_1")
		else:
			animation_player.play("attack_down_1")
		is_attacking = true
		attack_cooldown = 0.6

func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)
				
func update_hitbox_detection() -> void:
	if health > 0:
		if Time.get_ticks_msec() - t > 1000:
			var bodies = hitbox_area.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group("enemies"):
					var enemy: Enemy = body
					damage(1)
			t = Time.get_ticks_msec()

func damage(amount: int):
	health -= amount
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
		die()
		
func die():
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	GameManager.gameOver = true
	gameOverLabel.show()
	queue_free()

func heal(amount:int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	return health
	
func update_ritual():
	var ritual = ritual_scene.instantiate()
	add_child(ritual)
