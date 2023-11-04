extends TextureProgressBar


func _process(delta):
	HP_updating()

func HP_updating(body):
	self.value = body.health
