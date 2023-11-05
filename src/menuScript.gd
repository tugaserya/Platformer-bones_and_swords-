extends Node2D

var BG = load("res://scenes/back_ground.tscn")
var newBG = BG.instantiate()
func _ready():
	add_child(newBG)

func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/level.tscn")
