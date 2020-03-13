extends KinematicBody

var mouse_detected = false

var player_in_range = false

onready var mat = preload("res://Materials/NPC.tres").duplicate(true)

func _ready():
	randomize()
	$MeshInstance.mesh = $MeshInstance.mesh.duplicate(true)
	$MeshInstance.mesh.surface_set_material(0, mat)
	var col = Color(rand_range(0,1),rand_range(0,1),rand_range(0,1))
#	print(col)
	mat.set_albedo(col)
	#$MeshInstance.mesh.surface_get_material(0).set_albedo(col)
	
	add_to_group("npc")

func _process(delta):
	control_outline()
#	print(get_name() + " " + str(mouse_detected))

func control_outline():
	var outline = $MeshInstance.mesh.surface_get_material(0).get_next_pass()
	outline.params_grow = mouse_detected


func _on_Camera_npc_not_under_mouse():
	mouse_detected = false


func _on_Camera_npc_under_mouse(target):
	if target.get_name() == get_name():
		mouse_detected = true
	else:
		mouse_detected = false
