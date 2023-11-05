extends CharacterBody2D

const SPEED = 150.0
const RUNNING_SPEED = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_health = 100
var current_health = max_health
var attack_force_value = 50
var taking_damage = false
var enemy_in_range = false
var enemy
var player_attacking = false

@onready var animation = $AnimatedSprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction = Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("Runing"):
		run(direction)
	else:
		walk(direction)

	if Input.is_action_just_pressed("attack") and animation.animation != "attak":
		player_attacking = true
		velocity.x = 0
		animation.play("attak")
		if enemy_in_range and enemy:
			attacking(enemy)
		await animation.animation_finished
		player_attacking = false
		
	move_and_slide()

func walk(direction):
	if not taking_damage and not player_attacking:
		velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
		animation.play("Run" if direction else "idle" if velocity.y == 0 else animation.animation)
		$AnimatedSprite2D.flip_h = direction < 0

func run(direction):
	if not taking_damage and not player_attacking:
		velocity.x = direction * RUNNING_SPEED if direction else move_toward(velocity.x, 0, RUNNING_SPEED)
		animation.play("Run" if direction else "idle" if velocity.y == 0 else animation.animation)
		$AnimatedSprite2D.flip_h = direction < 0
		
func take_damage(damage, direction):
	taking_damage = true
	velocity.x = 0
	position.x -= direction * 15
	current_health -= damage
	if current_health <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
	animation.play("stunhit")
	await animation.animation_finished
	taking_damage = false

func attacking(body):
	if is_instance_valid(body) and body.is_in_group("Knights") and body.alive:
		body.take_damage(attack_force_value, sign(self.position.x - body.position.x))

func _on_attack_zone_body_entered(body):
	if body and body.is_in_group("Knights"):
		enemy_in_range = true
		enemy = body

func _on_attack_zone_body_exited(body):
	if body and body.is_in_group("Knights"):
		enemy_in_range = false
		enemy = null
