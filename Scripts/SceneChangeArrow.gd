extends Spatial


export var sceneto = ""
export var scenefrom = ""

export var min_dist = 1.0

signal scenechangesignal (scene)
signal faraway(pos)
var connected_to_player = false

func _ready():
	connect("scenechangesignal", get_node("/root/SceneManager"), "_on_Door_scenechangesignal")

func check_dist_to_player():
	if (get_tree().get_nodes_in_group("player").size() < 1):
		return false
	if (get_translation() - get_tree().get_nodes_in_group("player")[0].get_translation()).length() < min_dist:
		return true
	return false

func _process(delta):
	connect_to_player()

func connect_to_player():
	if connected_to_player == true:
		return
	if (get_tree().get_nodes_in_group("player").size() < 1):
		connected_to_player = false
	else:
		connect("faraway", get_tree().get_nodes_in_group("player")[0], "move_to")
		connected_to_player = true

func _on_Camera_arrowclicked(target):
	if check_dist_to_player():
		if target == $Stick/StaticBody:
			emit_signal("scenechangesignal", sceneto, scenefrom)
		elif target == $Point/StaticBody:
			emit_signal("scenechangesignal", sceneto, scenefrom)
	else:
		if target == $Stick/StaticBody:
			emit_signal("faraway", get_translation())
		elif target == $Point/StaticBody:
			emit_signal("faraway", get_translation())


func _on_Camera_arrow_under_mouse(target):
	if target == $Stick/StaticBody or target == $Point/StaticBody:
		$Point/Highlight.visible = true
		$Stick/Highlight.visible = true


func _on_Camera_arrow_not_under_mouse():
	$Point/Highlight.visible = false
	$Stick/Highlight.visible = false
