extends KinematicBody

var mouse_detected = false

var player_in_range = false

onready var mat = preload("res://Materials/NPC.tres").duplicate(true)

var dialogue
var dialogue_iter = 0
var all_dialogue_received = false
signal dialogue_received_from_json(array_length)
signal send_dialogue(text)
signal dialogue_sent
signal dialogue_amount_sent(a)

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

func parse_dialogue():
	var file = File.new()
	file.open("res://JSON/testDialogue.json", File.READ)
	var data = parse_json(file.get_as_text())
	for actor in data.actors :
		if actor.name == "npc":
			dialogue = actor.dialogue
	emit_signal("dialogue_received_from_json", dialogue.size())

func sending_dialogue():
	emit_signal("send_dialogue", dialogue[dialogue_iter])
	dialogue_iter += 1
#	if dialogue.size() > 0:
#		dialogue_iter %= dialogue.size()
#	else:
#		dialogue_iter = 0
	emit_signal("dialogue_sent")

func _on_Camera_npc_not_under_mouse():
	mouse_detected = false

func _on_Camera_npc_under_mouse(target):
	if target.get_name() == get_name():
		mouse_detected = true
	else:
		mouse_detected = false

func _on_Camera_npc_clicked(target):
	if target.get_name() == get_name():
		all_dialogue_received = false
		parse_dialogue()

func _on_Player_dialogue_received_from_json(array_length):
	sending_dialogue()


func _on_Player_dialogue_sent():
	if dialogue_iter != dialogue.size():
		sending_dialogue()
	elif not all_dialogue_received:
		emit_signal("dialogue_amount_sent", dialogue.size())
		emit_signal("dialogue_sent")
	else:
		pass


func _on_DialogueBox_all_text_received():
	all_dialogue_received = true
