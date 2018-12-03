extends Control

onready var panelUpgrade1 = get_node("PanelUpgrade1")
onready var panelUpgrade2 = get_node("PanelUpgrade2")
onready var panelUpgrade3 = get_node("PanelUpgrade3")
onready var labelChoose = get_node("LabelChoose")
onready var panelUpgradeList = get_node("PanelUpgradeList")
var r1 = -1
var r2 = -1


func _ready():
	if globals.upgrades.size() > 1:
		for i in globals.upgrades.size():
			panelUpgradeList.get_child(i).visible = true
			panelUpgradeList.get_child(i).texture = load("res://sprites/upgrades/{n}.png".format({"n":globals.upgrades[i]}))
		randomize()
		r1 = randi() % globals.upgrades.size()
		r2 = randi() % globals.upgrades.size()
		while r1 == r2:
			r2 = randi() % globals.upgrades.size()
		panelUpgrade1.get_node("LabelUpgrade").text = globals.upgradeList[globals.upgrades[r1]].name
		panelUpgrade2.get_node("LabelUpgrade").text = globals.upgradeList[globals.upgrades[r2]].name
		panelUpgrade1.get_node("TextureUpgrade").texture = load("res://sprites/upgrades/{n}.png".format({"n":globals.upgrades[r1]}))
		panelUpgrade2.get_node("TextureUpgrade").texture = load("res://sprites/upgrades/{n}.png".format({"n":globals.upgrades[r2]}))
	elif globals.upgrades.size() == 1:
		panelUpgradeList.visible = false
		panelUpgrade1.visible = false
		panelUpgrade2.visible = false
		panelUpgrade3.visible = true
		labelChoose.text = "It has to go"
		panelUpgrade3.get_node("LabelUpgrade").text = globals.upgradeList[globals.upgrades[0]].name
		panelUpgrade3.get_node("TextureUpgrade").texture = load("res://sprites/upgrades/{n}.png".format({"n":globals.upgrades[0]}))
	else:
		get_tree().change_scene("res://scenes/FinalScore.tscn")
func _on_PanelUpgrade1_mouse_entered():
	panelUpgrade1.rect_scale = Vector2(1.1,1.1)



func _on_PanelUpgrade1_mouse_exited():
	panelUpgrade1.rect_scale = Vector2(1,1)


func _on_PanelUpgrade2_mouse_entered():
	panelUpgrade2.rect_scale = Vector2(1.1,1.1)


func _on_PanelUpgrade2_mouse_exited():
	panelUpgrade2.rect_scale = Vector2(1,1)


func _on_PanelUpgrade1_gui_input(ev):
	if ev.is_pressed():
		globals.upgrades.remove(r1)
		get_tree().change_scene("res://scenes/Root.tscn")


func _on_PanelUpgrade2_gui_input(ev):
	if ev.is_pressed():
		globals.upgrades.remove(r2)
		get_tree().change_scene("res://scenes/Root.tscn")

func _on_PanelUpgrade3_mouse_entered():
	panelUpgrade3.rect_scale = Vector2(1.1,1.1)


func _on_PanelUpgrade3_mouse_exited():
	panelUpgrade3.rect_scale = Vector2(1,1)


func _on_PanelUpgrade3_gui_input(ev):
	if ev.is_pressed():
		globals.upgrades.clear()
		get_tree().change_scene("res://scenes/Root.tscn")
