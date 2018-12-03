extends Label

func _ready():
	text = "Final Score:\n{s}".format({"s":globals.score})