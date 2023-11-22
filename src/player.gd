extends CharacterBody2D

const SPEED = 150.0
const RUNNING_SPEED = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var taking_damage = false
var enemy_in_range = false
var enemy
var player_attacking = false
var dodging = false

@onready var animation = $AnimatedSprite2D

func _ready():
	add_to_group("entity")

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
		if enemy_in_range and is_instance_valid(enemy):
			get_tree().call_group("can_be_attacked", "take_damage", PlayerStats.attack_force_value, sign(self.position.x - enemy.position.x))
		await animation.animation_finished
		player_attacking = false
		
	if Input.is_action_just_pressed("Dodge") and not player_attacking and not dodging:
		dodge(direction)
	move_and_slide()

func walk(direction):
	if not taking_damage and not player_attacking and not dodging:
		velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
		animation.play("Run" if direction else "idle" if velocity.y == 0 else animation.animation)
		$AnimatedSprite2D.flip_h = direction < 0

func run(direction):
	if not taking_damage and not player_attacking and not dodging:
		velocity.x = direction * RUNNING_SPEED if direction else move_toward(velocity.x, 0, RUNNING_SPEED)
		animation.play("Run" if direction else "idle" if velocity.y == 0 else animation.animation)
		$AnimatedSprite2D.flip_h = direction < 0
		
func dodge(direction):
	if not taking_damage:
		dodging = true
		$".".set_collision_layer_value(3,true)
		$".".set_collision_layer_value(1,false)
		$".".set_collision_layer_value(2,false)
		$".".set_collision_mask_value(1,false)
		animation.play("Rolling")
		$AnimatedSprite2D.flip_h = direction < 0
		velocity.x = direction * RUNNING_SPEED
		await animation.animation_finished
		$".".set_collision_mask_value(1,true)
		$".".set_collision_layer_value(1,true)
		$".".set_collision_layer_value(2,true)
		$".".set_collision_layer_value(3,false)
		velocity.x = 0
		animation.play("idle")
		await get_tree().create_timer(0.2).timeout
		dodging = false

func take_damage(damage, direction):
	if not dodging:
		taking_damage = true
		velocity.x = 0
		position.x -= direction * 15
		PlayerStats.current_health -= damage
		if PlayerStats.current_health <= 0:
			queue_free()
			remove_from_group("entity")
			get_tree().change_scene_to_file("res://scenes/finale_display.tscn")
		animation.play("stunhit")
		await animation.animation_finished
		taking_damage = false

func _on_attack_zone_body_entered(body):
	if body and body.is_in_group("Knights"):
		enemy_in_range = true
		enemy = body
		body.add_to_group("can_be_attacked")

func _on_attack_zone_body_exited(body):
	if body and body.is_in_group("Knights"):
		enemy_in_range = false
		enemy = null
		body.remove_from_group("can_be_attacked")

func change_value_of_money(incresing_value):
	PlayerStats.value_of_money += incresing_value
