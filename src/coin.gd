extends Area2D


func _on_body_entered(body):
	if is_instance_valid(body) and body.name == "Player":
		body.change_value_of_money(100)
		PlayerStats.change_score(100)
		$AnimatedSprite2D.play("jump")
		await $AnimatedSprite2D.animation_finished
		queue_free()
