extends Node

onready var panel1 = get_node("PanelUpgrade1")
onready var panel2 = get_node("PanelUpgrade2")
onready var panel3 = get_node("PanelUpgrade3")
onready var labelNr = get_node("LabelUpgradeNr")
var pickable = []
var picked = []
var upgrades = [{
				"name":"Gun Boots",
				"description":"Jumping causes\nbullets to come out\nof your feet"
				},
				{
				"name":"Assault Rifle",
				"description":"Allow you to shoot\nmuch faster"
				},
				{
				"name":"Laser Cannon",
				"description":"Replaces your\nWeapon with a slow\nbut powerful\nLaser Cannon"
				},
				{
				"name":"Sniper Scope",
				"description":"Zoom out a bunch"
				},
				{
				"name":"Jet Boots",
				"description":"Jet propulsion\nJumping"
				},
				{
				"name":"Drum Mag",
				"description":"Triples your\nMagazine Capacity"
				},
				{
				"name":"Swift Hands",
				"description":"Triples your\nReload Speed"
				},
				{
				"name":"Iron Skin",
				"description":"Allows you to\ntake an additional\nhit"
				}
				]

func _ready():
	randomize()
	globals.score = 0
	pickable = []
	var ups = []
	var r = randi() % upgrades.size()
	for i in range(3):
		while ups.has(upgrades[r]) || picked.has(r):
			r = randi() % upgrades.size()
		ups.append(upgrades[r])
		pickable.append(r)
		
	panel1.get_node("LabelNameUpgrade").text = ups[0].name
	panel1.get_node("LabelDescUpgrade").text = ups[0].description
	panel1.get_node("TextureUpgrade").texture = load("res://sprites/upgrades/{n}.png".format({"n":pickable[0]}))
	panel2.get_node("LabelNameUpgrade").text = ups[1].name
	panel2.get_node("LabelDescUpgrade").text = ups[1].description
	panel2.get_node("TextureUpgrade").texture = load("res://sprites/upgrades/{n}.png".format({"n":pickable[1]}))
	panel3.get_node("LabelNameUpgrade").text = ups[2].name
	panel3.get_node("LabelDescUpgrade").text = ups[2].description
	panel3.get_node("TextureUpgrade").texture = load("res://sprites/upgrades/{n}.png".format({"n":pickable[2]}))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func pickUpgrade(num):
	labelNr.text = "Choose Upgrade\n{n}/5".format({"n":picked.size()+2})
	if picked.size() < 5:
		picked.append(pickable[num-1])
		get_node("PanelPicked/TextureUpgrade{z}".format({"z":picked.size()})).visible = true
		get_node("PanelPicked/TextureUpgrade{z}".format({"z":picked.size()})).texture = load("res://sprites/upgrades/{n}.png".format({"n":picked[picked.size()-1]}))
		_ready()
	if picked.size() == 5:
		#picked = []
		globals.upgrades = picked
		get_tree().change_scene("res://scenes/Root.tscn")


func _on_PanelUpgrade1_gui_input(ev):
	if ev.is_pressed():
		pickUpgrade(1)


func _on_PanelUpgrade2_gui_input(ev):
	if ev.is_pressed():
		pickUpgrade(2)


func _on_PanelUpgrade3_gui_input(ev):
	if ev.is_pressed():
		pickUpgrade(3)


func _on_PanelUpgrade1_mouse_entered():
	panel1.rect_scale = Vector2(1.1,1.1)


func _on_PanelUpgrade1_mouse_exited():
	panel1.rect_scale = Vector2(1,1)


func _on_PanelUpgrade2_mouse_entered():
	panel2.rect_scale = Vector2(1.1,1.1)


func _on_PanelUpgrade2_mouse_exited():
	panel2.rect_scale = Vector2(1,1)


func _on_PanelUpgrade3_mouse_entered():
	panel3.rect_scale = Vector2(1.1,1.1)


func _on_PanelUpgrade3_mouse_exited():
	panel3.rect_scale = Vector2(1,1)
