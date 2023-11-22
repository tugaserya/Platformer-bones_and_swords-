extends Node2D


var ATK_change = false
var HP_change = false
var currentHP_change = false
@onready var player = $"../../../Player2/Player"

func _process(delta):
	if Input.is_action_just_pressed("Action"): 
		_on_button_pressed(player)

func _on_button_pressed(body):
	if ATK_change and PlayerStats.value_of_money >= 150:
		PlayerStats.attack_force_value += 30
		PlayerStats.value_of_money -= 150
	elif HP_change and PlayerStats.value_of_money >= 150:
		PlayerStats.max_health += 20
		PlayerStats.current_health += 20
		PlayerStats.value_of_money -= 150
	elif currentHP_change and PlayerStats.value_of_money >= 100 and PlayerStats.current_health < PlayerStats.max_health:
		PlayerStats.current_health += PlayerStats.max_health - PlayerStats.current_health
		PlayerStats.value_of_money -= 100

func _on_up_damage_body_entered(body):
	if body.name == "Player":
		ATK_change = true
		$Button.text = "ATK+ 30" + "\n$150"
func _on_up_damage_body_exited(body):
	if body.name == "Player":
		ATK_change = false

func _on_up_max_hp_body_entered(body):
	if body.name == "Player":
		HP_change = true
		$Button.text = "MAX HP+ 20" + "\n$150"
func _on_up_max_hp_body_exited(body):
	if body.name == "Player":
		HP_change = false

func _on_up_current_hp_body_entered(body):
	if body.name == "Player":
		currentHP_change = true
		$Button.text = "FULL HEALL" + "\n$100"
func _on_up_current_hp_body_exited(body):
	if body.name == "Player":
		currentHP_change = false
