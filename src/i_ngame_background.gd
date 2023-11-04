extends ParallaxBackground

var background_speed = 100


func _physics_process(delta):
	scroll_offset.x -= background_speed * delta
