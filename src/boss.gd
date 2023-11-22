extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_1 = $Animation_1
@onready var animation_2 = $Animation_2
var chase = false
var alive = true
var max_health = 3000
var current_health = max_health
var is_attacking = false
@onready var player = $"../../Player2/Player"


func _ready():
	add_to_group("Knights")
	
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if alive and animation_2.animation != "Attak_1":
		var direction = (player.position - self.position).normalized()
		animation_1.play("idle" if not chase else "idle")
		animation_1.flip_h = direction.x < 0
	move_and_slide()
	
func _on_agressive_area_body_entered(body):
	if body.name == "Player" and alive:
		chase = true

func _on_agressive_area_body_exited(body):
	if body.name == "Player" and alive:
		chase = false
		
func _on_deal_damage_body_entered(body):
	if alive and body.name == "Player" and not is_attacking:
		body.add_to_group("Player")
		if alive and $deal_damage.overlaps_body(player):
			await get_tree().create_timer(0.8).timeout
			attacking(player)

func attacking(body):
	if alive:
		is_attacking = true
		animation_1.visible = false
		animation_2.visible = true
		animation_2.play("Attak_1")
		await get_tree().create_timer(1).timeout
		if body.is_in_group("Player") and alive:
			body.take_damage(20, sign(self.position.x - body.position.x))
		await animation_2.animation_finished
		animation_1.visible = true
		animation_2.visible = false
		animation_1.play("idle")
		await get_tree().create_timer(1).timeout
		is_attacking = false
		_on_deal_damage_body_entered(player)

func _on_deal_damage_body_exited(body):
	if alive and body.name == "Player":
		body.remove_from_group("Player")

func take_damage(damage, direction):
	current_health -= damage
	if current_health <= 0:
		death()

func death():
	alive = false
	current_health = 0
	animation_1.play("death")
	PlayerStats.change_score(1000)
	await animation_1.animation_finished
	queue_free()
	remove_from_group("Knights")
