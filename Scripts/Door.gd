extends Spatial

onready var ap = $Meshes/AnimationPlayer

export var openable = false
export var scenechange = false
export var sceneto = ""
export var scenefrom = ""

export var min_dist = 1.0

signal scenechangesignal (scene)
signal faraway(pos)

var open = false
var connected_to_player = false

func _ready():
	add_to_group("door")
	connect("scenechangesignal", get_node("/root/SceneManager"), "_on_Door_scenechangesignal")
	connect_to_player()

func _process(delta):
	connect_to_player()

func _On_Scale(s):
	min_dist*=s

func connect_to_player():
	if connected_to_player == true:
		return
	if (get_tree().get_nodes_in_group("player").size() < 1):
		connected_to_player = false
	else:
		connect("faraway", get_tree().get_nodes_in_group("player")[0], "move_to")
		connected_to_player = true

func _on_Camera_doorclicked(target):
	if check_dist_to_player():
		if openable:
			if target == $Meshes/Doorframe/StaticBody:
				opcl()
			elif target == $Meshes/Window/StaticBody:
				opcl()
		if scenechange:
			#connect("scenechangesignal", get_node("/root/SceneManager"), "_on_Door_scenechangesignal")
			if target == $Meshes/Doorframe/StaticBody:
				emit_signal("scenechangesignal", sceneto, scenefrom)
			elif target == $Meshes/Window/StaticBody:
				emit_signal("scenechangesignal", sceneto, scenefrom)
	else:
		if target == $Meshes/Doorframe/StaticBody:
			emit_signal("faraway", (get_translation()+Vector3(0, 0, -1)).linear_interpolate(get_tree().get_nodes_in_group("player")[0].get_translation(), 0.2))
		elif target == $Meshes/Window/StaticBody:
			emit_signal("faraway", (get_translation()+Vector3(0, 0, -1)).linear_interpolate(get_tree().get_nodes_in_group("player")[0].get_translation(), 0.2))

func check_dist_to_player():
	if (get_tree().get_nodes_in_group("player").size() < 1):
		return false
	if (get_translation() - get_tree().get_nodes_in_group("player")[0].get_translation()).length() < min_dist:
		return true
	return false

func opcl():
	if open:
		ap.play("SwingClose")
		open = false
	else:
		ap.play("SwingOpen")
		open = true
