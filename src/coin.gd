extends Area2D


func _on_body_entered(body):
	if body.name == "Player":
		$AnimatedSprite2D.play("jump")
		await $AnimatedSprite2D.animation_finished
		queue_free()
