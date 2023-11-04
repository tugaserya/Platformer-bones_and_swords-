extends CharacterBody2D

const SPEED = 200.0 # скорсть движения для противника

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation = $AnimatedSprite2D 

var chase = false # определение базовых характеристик и состояний противника
var Dead = false
var alive = true
var max_health = 100
var current_health = max_health
var taking_damage = false

func _physics_process(delta): # реализация преследования игрока и взаимодействий с объектами
	if not is_on_floor():# гравитация 
		velocity.y += gravity * delta
		
	var player = $"../../Player2/Player"
	var direction = (player.position - self.position).normalized() # определения направления противника взависимости от позиции игрока
	
	if alive and animation.animation != "attak" and taking_damage == false: # ходьба и разворот от напраления
		if chase:
			velocity.x = direction.x * SPEED
			animation.play("walk")
		else:
			velocity.x = 0
			animation.play("idle")
		
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif direction.x > 0:
			$AnimatedSprite2D.flip_h = false
			
	move_and_slide()





func _on_agressive_area_body_entered(body): # преследование игрока
	if body.name == "Player":
		chase = true

func _on_agressive_area_body_exited(body):
	if body.name == "Player":
		chase = false



func _on_death_body_entered(body): # смерть противника если игрок прыгнулна него
	if body.name == "Player":
		body.velocity.y -= 300
		death()

func  death():  # реализация смерти
	alive = false
	current_health = 0
	animation.play("death")
	await animation.animation_finished
	queue_free()



func _on_deal_damage_body_entered(body): # нанесение урона игроку 
	if body.name == "Player" and alive and taking_damage == false:
		body.add_to_group("Player")
		await get_tree().create_timer(0.5).timeout
		animation.play("attak")
		await get_tree().create_timer(0.4).timeout
		if body.is_in_group("Player"):
			body.take_damage(20)
		await animation.animation_finished
		animation.play("idle")
		if alive and $Deal_damage.overlaps_body($"../../Player2/Player"):
			await get_tree().create_timer(1).timeout
			_on_deal_damage_body_entered($"../../Player2/Player")
func _on_deal_damage_body_exited(body):
	if body.name == "Player" and alive:
		body.remove_from_group("Player")



func take_damage(damage): # получение урона
	taking_damage = true
	current_health -= damage
	if current_health <= 0:
		death()
	else:
		animation.play("stunhit")
	await animation.animation_finished
	taking_damage = false
