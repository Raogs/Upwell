extends Node2D

var airborne = true
var drop = false
var lastDir = "right"
var curjump = 0
var maxjumps = 2
var airtime = 0
var gravity = 0
var globaldelta = 0
onready var cam = get_parent().get_node("CameraRoot")
var bullet = preload("res://scenes/BulletRoot.tscn")
var laser = preload("res://scenes/LaserRoot.tscn")
var blockRight = false
var blockLeft = false
var blockTop = false
onready var areaDown = get_node("PlayerAreaBelow")
onready var areaUp = get_node("PlayerAreaAbove")
onready var shotTimer = get_node("PlayerShotTimer")
onready var reloadTimer = get_node("PlayerReloadTimer")
onready var deathTimer = get_node("PlayerDeathTimer")
onready var animTimer = get_node("PlayerAnimTimer")
var canShoot = true
var rf = false
var topCollide = false
onready var root = get_parent()
onready var uiRoot = root.get_node("UiRoot")
var ammo = 10
var hp = 1
onready var invulTimer = get_node("PlayerInvulTimer")
onready var audioSlam = root.get_node("AudioSlam")
onready var audioJump = get_node("PlayerAudioJump")
onready var audioLaser = get_node("PlayerAudioLaser")
onready var audioShot = get_node("PlayerAudioShot")
onready var audioIronDamage = get_node("PlayerAudioIronDamage")
onready var audioDeath = root.get_node("PlayerAudioDeath")
onready var audioReload = get_node("PlayerAudioReload")
onready var areaBelow = get_node("PlayerAreaBelow")
onready var labelScore = root.get_node("UiRoot/LabelScore")
onready var mySprite = get_node("PlayerSprite")
var spriteRunLeft = preload("res://sprites/player/playerRunLeft.png")
var spriteRunRight = preload("res://sprites/player/playerRun.png")
var spriteFallLeft = preload("res://sprites/player/playerFallLeft.png")
var spriteFallRight = preload("res://sprites/player/playerFall.png")
var invulerable = false
var time = 0

func _ready():
	animTimer.start()
	if globals.upgrades.has(3):
		OS.window_size = Vector2(256,768)
	else:
		OS.window_size = Vector2(256,512)
	if globals.upgrades.has(2):
		shotTimer.wait_time = 2.25
	if globals.upgrades.has(1):
		shotTimer.wait_time = 0.2
		if globals.upgrades.has(2):
			shotTimer.wait_time = 1
		rf = true
	if globals.upgrades.has(2):
		ammo = 3
	if globals.upgrades.has(5):
		ammo = 30
		if globals.upgrades.has(2):
			ammo = 9
	updateAmmo()
	if globals.upgrades.has(2):
		reloadTimer.wait_time = 5
	if globals.upgrades.has(6):
		reloadTimer.wait_time = 1
		if globals.upgrades.has(2):
			reloadTimer.wait_time = 2
	if globals.upgrades.has(7):
		uiRoot.get_node("HealthIcon").texture = load("res://sprites/heartIron.png")
		hp = 2
	pass


func updateAmmo():
	var ammoRoot = uiRoot.get_node("AmmoRoot")
	var ammoIcons = []
	for i in [1,2,3]:
		for j in ammoRoot.get_node("PanelAmmo{n}".format({"n":i})).get_children():
			ammoIcons.append(j)
	for i in range(ammoIcons.size()):
		if i < ammo:
			ammoIcons[i].visible = true
		else:
			ammoIcons[i].visible = false

func move(dir, delta):
		position.x += dir * delta

func jump(delta):
	if curjump <= maxjumps:
		translate(Vector2(0,-airtime * delta))
		if airtime > 0:
			airtime -= 600 * delta
			if lastDir == "left":
				mySprite.texture = spriteFallLeft
			else:
				mySprite.texture = spriteFallRight
		else:
			airtime = 0
			airborne = false


func _process(delta):
	
	labelScore.text = "Score:\n{s}".format({"s":globals.score})
	globaldelta = delta
	cam.position.y = position.y
	
	#Movement
	if position.y >= 2000:
		position = Vector2(125,700)
		gravity = 0
		airtime = 0
		airborne = true
	if Input.is_key_pressed(KEY_RIGHT) && !blockRight:
		mySprite.texture = spriteRunRight
		lastDir = "right"
		move(256, delta)
		
	if Input.is_key_pressed(KEY_LEFT) && !blockLeft:
		mySprite.texture = spriteRunLeft
		lastDir = "left"
		move(-256, delta)
		
	if Input.is_action_just_pressed("jump"):
		if !airborne && !blockTop:
			if globals.upgrades.has(0):
				var newBullet = bullet.instance()
				get_parent().add_child(newBullet)
				newBullet.position = position
				newBullet.speed = 1000
			airborne = true
			airtime = 700
			if globals.upgrades.has(4):
				airtime = 1200
			curjump += 1
			audioJump.play()
		else:
			if curjump < maxjumps:
				if globals.upgrades.has(0):
					var newBullet = bullet.instance()
					get_parent().add_child(newBullet)
					newBullet.position = position
					newBullet.speed = 1000
				airtime = 700
				if globals.upgrades.has(4):
					airtime = 1200
				gravity = 0
				curjump += 1
				audioJump.play()
			
	for i in areaUp.get_overlapping_areas():
		if i.name.begins_with("ColliderArea"):
			topCollide = true
			break
		else:
			topCollide = false
	if airtime > 0 && !topCollide:
		jump(delta)
		
	if airborne:
		if gravity < 20000:
			gravity += 800 * delta
		elif gravity != 20000:
			gravity = 20000
		translate(Vector2(0,gravity * delta))
	elif gravity != 0:
		gravity = 0
	areaDown.get_node("PlayerShape").scale = Vector2(0.5,gravity/12*delta+1)
	areaDown.get_node("PlayerShape").position.y = gravity*delta	
		
	#Shoot
	if canShoot:
		if !rf:
			if Input.is_action_just_pressed("shoot_down"):
				shoot(1000)
		elif Input.is_action_pressed("shoot_down"):
			shoot(1000)
			
		if !rf:
			if Input.is_action_just_pressed("shoot_up"):
				shoot(-1000)
		elif Input.is_action_pressed("shoot_up"):
			shoot(-1000)
		
	pass


func shoot(speed):
	if ammo > 0:
		ammo -= 1
		updateAmmo()
		if !globals.upgrades.has(2):
			audioShot.play()
			if speed > 0:
				if !blockTop:
					gravity /= 8
					if airtime != 0:
						airtime += 150
					else:
						airtime += 400
					airborne = true
			elif airborne:
				gravity += 350
						
						
			var newBullet = bullet.instance()
			root.add_child(newBullet)
			newBullet.position = position
			newBullet.speed = speed
		else:
			if speed > 0:
				if !blockTop:
					gravity /= 8
					if airtime != 0:
						airtime += 500
					else:
						airtime += 1000
					airborne = true
			elif airborne:
				gravity += 1350
			var newLaser = laser.instance()
			root.add_child(newLaser)
			newLaser.position = position + Vector2(0,speed/6.25)
			audioLaser.play()
		canShoot = false
		shotTimer.start()
	if ammo <= 0 && reloadTimer.time_left == 0:
		audioReload.play()
		reloadTimer.start()
	

func _on_PlayerAreaBelow_area_exited(area):
	drop = false
	for i in areaBelow.get_overlapping_areas():
		if i.name.begins_with("ColliderArea") && i != area:
			drop = false
			break
		else:
			drop = true


	if area.name.begins_with("ColliderArea") && drop:
		airborne = true
		gravity += 200
		pass
			

func _on_PlayerAreaAbove_area_exited(area):
	blockTop = false


func _on_PlayerAreaBelow_area_entered(area):
	if area.name.begins_with("ColliderArea"):
		if area.position.y >= position.y:
			airborne = false
			curjump = 0
			airtime = 0
			if gravity > 5000:
				audioSlam.set_bus("Slam Bus > 5000")
			elif gravity > 1000:
				audioSlam.set_bus("Slam Bus > 1000")
			else:
				audioSlam.set_bus("Slam Bus")
			gravity = 0
			if drop:
				audioSlam.play()
				if lastDir == "left":
					mySprite.texture = spriteRunLeft
				else:
					mySprite.texture = spriteRunRight
			position.y = area.position.y - area.get_child(0).shape.extents.y * area.scale.y - 10

func _on_PlayerAreaAbove_area_entered(area):
	if area.name.begins_with("ColliderArea"):
		if area.position.y - area.get_child(0).shape.extents.y * area.scale.y <= position.y:
			airtime = 0
			gravity /= 2
			blockTop = true
			position.y = area.position.y + area.get_child(0).shape.extents.y * area.scale.y + 10

func _on_PlayerAreaRight_area_entered(area):
	if area.name.begins_with("ColliderArea"):
		blockRight = true


func _on_PlayerAreaLeft_area_entered(area):
	if area.name.begins_with("ColliderArea"):
		blockLeft = true


func _on_PlayerAreaRight_area_exited(area):
	if area.name.begins_with("ColliderArea"):
		blockRight = false


func _on_PlayerAreaLeft_area_exited(area):
	if area.name.begins_with("ColliderArea"):
		blockLeft = false


func _on_PlayerShotTimer_timeout():
	canShoot = true


func _on_PlayerArea_area_entered(area):
	if area.name.begins_with("StageClearArea"):
		if time <= 200:
			globals.score += 200 - time
		get_tree().change_scene("res://scenes/LooseUpgradeRoot.tscn")
	if area.name == "EnemyArea" && !invulerable:
		invulTimer.start()
		invulerable = true
		hp -= 1
		if hp <= 0:
			audioDeath.play()
			uiRoot.get_node("HealthIcon").visible = false
			deathTimer.start()
			visible = false
		elif hp == 1:
			audioIronDamage.play()
			globals.score -= 100
			uiRoot.get_node("HealthIcon").texture = load("res://sprites/heart.png")


func _on_PlayerReloadTimer_timeout():
	if globals.upgrades.has(5):
		if globals.upgrades.has(2):
			ammo = 9
		else:
			ammo = 30
	else:
		if globals.upgrades.has(2):
			ammo = 3
		else:
			ammo = 10
	updateAmmo()


func _on_PlayerInvulTimer_timeout():
	invulerable = false


func _on_PlayerDeathTimer_timeout():
	get_tree().change_scene("res://scenes/MenuRoot.tscn")


func _on_ScoreTimer_timeout():
	time += 1


func _on_PlayerAnimTimer_timeout():
	if (Input.is_key_pressed(KEY_LEFT) || Input.is_key_pressed(KEY_RIGHT)) || airtime > 0:
		if mySprite.frame < 4:
			mySprite.frame += 1
		else:
			mySprite.frame = 0
