extends Label




func _process(delta):
	text = "$: " + str(PlayerStats.value_of_money)
