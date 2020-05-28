extends Spatial

onready var ap = $Meshes/AnimationPlayer

export var openable = false
export var scenechange = false
export var sceneto = ""
export var scenefrom = ""

signal scenechangesignal (scene)

var open = false

func _ready():
	connect("scenechangesignal", get_node("/root/SceneManager"), "_on_Door_scenechangesignal")


func _on_Camera_doorclicked(target):
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
		

func opcl():
	if open:
		ap.play("SwingClose")
		open = false
	else:
		ap.play("SwingOpen")
		open = true
