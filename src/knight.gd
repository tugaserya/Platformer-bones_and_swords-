extends CharacterBody2D

const SPEED = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation = $AnimatedSprite2D 
var chase = false
var alive = true
var max_health = 150
var current_health = max_health
var taking_damage = false
var is_attacking = false
@onready var player = $"../../Player2/Player"

func _ready():
	add_to_group("Knights")
	add_to_group("entity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if alive and animation.animation != "attak" and not taking_damage:
		var direction = (player.position - self.position).normalized()
		velocity.x = SPEED * direction.x if chase else 0
		animation.play("walk" if chase else "idle")
		$AnimatedSprite2D.flip_h = direction.x < 0
	move_and_slide()

func _on_agressive_area_body_entered(body):
	if body.name == "Player" and alive:
		chase = true

func _on_agressive_area_body_exited(body):
	if body.name == "Player" and alive:
		chase = false

func _on_death_body_entered(body):
	if body.name == "Player" and alive:
		body.velocity.y -= 300
		take_damage(50, 0)

func death():
	alive = false
	current_health = 0
	velocity.x = 0
	animation.play("death")
	await animation.animation_finished
	queue_free()
	remove_from_group("Knights")
	remove_from_group("entity")
	

func _on_deal_damage_body_entered(body):
	if alive and body.name == "Player" and not taking_damage and not is_attacking:
		body.add_to_group("Player")
		if alive and $Deal_damage.overlaps_body(player) and not taking_damage:
			await get_tree().create_timer(0.8).timeout
			attacking(player)

func _on_deal_damage_body_exited(body):
	if alive and body.name == "Player":
		body.remove_from_group("Player")

func attacking(body):
	if alive and not taking_damage:
		is_attacking = true
		velocity.x = 0
		animation.play("attak")
		await get_tree().create_timer(0.4).timeout
		if body.is_in_group("Player") and not taking_damage and alive:
			body.take_damage(20, sign(self.position.x - body.position.x))
		await animation.animation_finished
		animation.play("idle")
		await get_tree().create_timer(0.5).timeout
		is_attacking = false
		_on_deal_damage_body_entered(player)

func take_damage(damage, direction):
	taking_damage = true
	velocity.x = 0
	position.x -= direction * 10
	current_health -= damage
	if current_health <= 0:
		death()
	else:
		animation.play("stunhit")
	await animation.animation_finished
	taking_damage = false
