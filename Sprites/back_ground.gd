extends ParallaxBackground

var background_speed = 100 # скорость движения элементов фона


func _physics_process(delta):
	scroll_offset.x -= background_speed * delta # обновление смещения для элементов фона в меню
