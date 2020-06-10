extends KinematicBody

var mouse_detected = false

export var min_dist = 1.0

export var conversationJSONname = "res://JSON/"

signal conversation(name)
signal faraway(pos)

var connected_to_player = false

export(Color) var skin_col
export(Color) var top_col
export(Color) var bot_col
export(Color) var shoe_col

onready var skin_parts = [	get_node("Person").find_node("Head"),
							get_node("Person").find_node("Neck"),
							get_node("Person").find_node("LHand"),
							get_node("Person").find_node("LElbow"),
							get_node("Person").find_node("LForeArm"),
							get_node("Person").find_node("RHand"),
							get_node("Person").find_node("RElbow"),
							get_node("Person").find_node("RForeArm")]

onready var top_parts = [	get_node("Person").find_node("LShoulder"),
							get_node("Person").find_node("RShoulder"),
							get_node("Person").find_node("LArm"),
							get_node("Person").find_node("RArm"),
							get_node("Person").find_node("Chest"),
							get_node("Person").find_node("Midriff")]

onready var bottom_parts = [get_node("Person").find_node("Hips"),
							get_node("Person").find_node("RHipJoint"),
							get_node("Person").find_node("LHipJoint"),
							get_node("Person").find_node("RULeg"),
							get_node("Person").find_node("LULeg"),
							get_node("Person").find_node("RKnee"),
							get_node("Person").find_node("LKnee"),
							get_node("Person").find_node("LLLeg"),
							get_node("Person").find_node("RLLeg")]

onready var shoe_parts = [	get_node("Person").find_node("LAnkle"),
							get_node("Person").find_node("RAnkle"),
							get_node("Person").find_node("RFoot"),
							get_node("Person").find_node("LFoot")]

onready var anim = $Person/AnimationPlayer

var is_hurt = false

func _ready():
	_apply_colours()
	
	add_to_group("npc")

func _process(delta):
	control_outline()
	connect_to_player()
	if is_hurt:
		anim.play("Hurt")
	else:
		anim.play("Idle")
	#_apply_colours() # For editing the colours while placing the NPCs

func _On_Scale(s):
	min_dist*=s

func control_outline():
	for part in skin_parts:
		part.get_surface_material(0).get_next_pass().params_grow = mouse_detected
		
	for part in top_parts:
		var m = part.get_surface_material(0).get_next_pass()
		m.params_grow = mouse_detected
	
	for part in bottom_parts:
		var m = part.get_surface_material(0).get_next_pass()
		m.params_grow = mouse_detected
	
	for part in shoe_parts:
		var m = part.get_surface_material(0).get_next_pass()
		m.params_grow = mouse_detected


func _on_Camera_npc_not_under_mouse():
	mouse_detected = false

func _on_Camera_npc_under_mouse(target):
	if target.get_name() == get_name():
		mouse_detected = true
	else:
		mouse_detected = false

func _apply_colours():
	for part in skin_parts:
		var m = part.get_surface_material(0).duplicate(true)
		var n = part.get_surface_material(0).get_next_pass().duplicate(true)
		m.set_albedo(skin_col)
		part.set_surface_material(0, m)
		part.get_surface_material(0).set_next_pass(n)
	
	for part in top_parts:
		var m = part.get_surface_material(0).duplicate(true)
		m.set_albedo(top_col)
		part.set_surface_material(0, m)
	
	for part in bottom_parts:
		var m = part.get_surface_material(0).duplicate(true)
		m.set_albedo(bot_col)
		part.set_surface_material(0, m)
	
	for part in shoe_parts:
		var m = part.get_surface_material(0).duplicate(true)
		m.set_albedo(shoe_col)
		part.set_surface_material(0, m)



func check_dist_to_player():
	if (get_tree().get_nodes_in_group("player").size() < 1):
		return false
	if (get_translation() - get_tree().get_nodes_in_group("player")[0].get_translation()).length() < min_dist:
		return true
	return false

func connect_to_player():
	if connected_to_player == true:
		return
	if (get_tree().get_nodes_in_group("player").size() < 1):
		connected_to_player = false
	else:
		connect("faraway", get_tree().get_nodes_in_group("player")[0], "move_to")
		connected_to_player = true

func _on_Camera_npc_clicked(target):
	if check_dist_to_player():
		if target.get_name() == get_name():
			emit_signal("conversation", conversationJSONname)
	else:
		if target.get_name() == get_name():
			var d = (get_translation() - get_tree().get_nodes_in_group("player")[0].get_translation()).length()
			
			emit_signal("faraway", get_translation().linear_interpolate(get_tree().get_nodes_in_group("player")[0].get_translation(), min_dist/d-0.05))


func _on_Courtyard_npcshurt():
	is_hurt = true
