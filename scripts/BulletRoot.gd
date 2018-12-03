extends Node2D

var speed = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	translate(Vector2(0,speed * delta))
	pass


func _on_BulletArea_area_entered(area):
	if area.name.begins_with("ColliderArea"):
		queue_free()
	elif area.name.begins_with("EnemyArea"):
		queue_free()
