extends Node2D



func _on_LaserArea_area_entered(area):
	if area.name == "EnemyArea":
		globals.score += 10
		area.get_parent().queue_free()


func _on_LaserTimer_timeout():
	queue_free()
