extends Spatial


export var sceneto = ""
export var scenefrom = ""

signal scenechangesignal (scene)

func _ready():
	connect("scenechangesignal", get_node("/root/SceneManager"), "_on_Door_scenechangesignal")



func _on_Camera_arrowclicked(target):
	if target == $Stick/StaticBody:
		emit_signal("scenechangesignal", sceneto, scenefrom)
	elif target == $Point/StaticBody:
		emit_signal("scenechangesignal", sceneto, scenefrom)


func _on_Camera_arrow_under_mouse(target):
	if target == $Stick/StaticBody or target == $Point/StaticBody:
		$Point/Highlight.visible = true
		$Stick/Highlight.visible = true


func _on_Camera_arrow_not_under_mouse():
	$Point/Highlight.visible = false
	$Stick/Highlight.visible = false
