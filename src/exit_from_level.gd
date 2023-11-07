extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("Action") and $Button.visible: # Замените KEY_ENTER на нужную вам клавишу
		_on_button_pressed()
		
func _on_exit_zone_body_entered(body):
	if body.name == "Player":
		$Button.visible = true

func _on_exit_zone_body_exited(body):
	if body.name == "Player":
		$Button.visible = false


func _on_button_pressed():
	get_tree().change_scene_to_file("res://node_2d.tscn")
