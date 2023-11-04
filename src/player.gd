extends CharacterBody2D


const SPEED = 300.0 # скорсть для движения и скорсть для прыжка
const JUMP_VELOCITY = -400.0


var max_health = 100 # определение базовых характеристик и состояний игрока
var current_health = max_health
var attack_force_value = 50
var taking_damage = false
var enemy_in_range = false
var enemy
var player_attacking = false



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation = $AnimatedSprite2D



func _physics_process(delta): # реализация управления и взаимодейстивия с объектами
	# Add the gravity.
	if not is_on_floor(): # прижок и графитация
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Rolling")

	var direction = Input.get_axis("move_left", "move_right") # движение влево и вправо
	if taking_damage == false and player_attacking == false:
		if direction:
			velocity.x = direction * SPEED
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.y == 0:
				animation.play("idle")

		if direction < 0: # разворот анимации в зависимости от направления
			$AnimatedSprite2D.flip_h = true
		elif direction > 0:
			$AnimatedSprite2D.flip_h = false
			
	if Input.is_action_just_pressed("attack") and animation.animation != "attak": # атака игрока
		player_attacking = true
		velocity.x = 0
		animation.play("attak")
		if enemy_in_range:
			attacking(enemy)
		await animation.animation_finished
		player_attacking = false
		
	move_and_slide()





#  код ниже обрабатывает атаку как игроком так и получение атак
func take_damage(damage):
	taking_damage = true
	velocity.x = 0
	current_health -= damage
	if current_health <= 0:
		death()
	animation.play("stunhit")
	await animation.animation_finished
	taking_damage = false

func death():
	queue_free()
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

func attacking(body):
	if body and body.name == "Knight" and body.alive:
		if body and body.alive:
			body.take_damage(attack_force_value)

func _on_attack_zone_body_entered(body):
	if body.name == "Knight":
		enemy_in_range = true
		enemy = body

func _on_attack_zone_body_exited(body):
	if body.name == "Knight":
		enemy_in_range = false
