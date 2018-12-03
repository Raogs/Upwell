extends Node2D

var dir = 100
onready var areaBelowLeft = get_node("EnemyAreaBelowLeft")
onready var areaBelowRight = get_node("EnemyAreaBelowRight")
var spriteRight = preload("res://sprites/enemy/enemy.png")
var spriteLeft = preload("res://sprites/enemy/enemyLeft.png")
onready var mySprite = get_node("EnemySprite")

func move(speed):
	position.x += speed

func _process(delta):
	move(dir*delta)
	


func _on_EnymArea_area_entered(area):
	if area.name.begins_with("BulletArea"):
		globals.score += 10
		queue_free()


func _on_EnemyAreaBelowLeft_area_entered(area):
	if area.name.begins_with("TurnerArea"):
		mySprite.texture = spriteRight
		dir = 100


func _on_EnemyAreaBelowRight_area_entered(area):
	if area.name.begins_with("TurnerArea"):
		mySprite.texture = spriteLeft
		dir = -100
