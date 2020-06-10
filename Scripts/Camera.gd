extends Camera

const ray_length = 1000

signal enemy_under_mouse(target)
signal enemy_not_under_mouse

signal npc_under_mouse(target)
signal npc_not_under_mouse
signal npc_clicked(target)

var turn_actor

signal moveclick(target)
signal mousetrack(target)

signal doorclicked(target)

signal arrow_under_mouse(target)
signal arrow_not_under_mouse
signal arrowclicked(target)

signal book_under_mouse(target)
signal book_not_under_mouse
signal bookclicked(target)

export(Vector3) var offset_from_player = Vector3(0,0,0)
 
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1 and turn_actor == "Player":
		if raycast_mouse_to_world(3):
			emit_signal("doorclicked", raycast_mouse_to_world(3).collider)
		elif raycast_mouse_to_world(20):
			emit_signal("arrowclicked", raycast_mouse_to_world(20).collider)
		elif raycast_mouse_to_world(2):
			#clicking enemies for attacks
			if raycast_mouse_to_world(2).collider.is_in_group("enemy"):
				if get_node("../TurnOrderManager/Navigation/Player")._dist_check(raycast_mouse_to_world(1).position):
					get_tree().call_group("player", "move_to_enemy", raycast_mouse_to_world(2).collider)
			#clicking NPCs for dialogue
			elif raycast_mouse_to_world(2).collider.is_in_group("npc"):
				emit_signal("npc_clicked", raycast_mouse_to_world(2).collider)
			#clicking for movement
		elif raycast_mouse_to_world(6):
			print("bookclicked")
			
			emit_signal("bookclicked", raycast_mouse_to_world(6).collider)
		elif raycast_mouse_to_world(1):
			emit_signal("moveclick", raycast_mouse_to_world(1).position)
#			if get_node("../TurnOrderManager/Navigation/Player")._dist_check(raycast_mouse_to_world(1).position):
#				get_tree().call_group("player", "move_to", raycast_mouse_to_world(1).position)
		

# warning-ignore:unused_argument
func _process(delta):
	if raycast_mouse_to_world(2):
		if raycast_mouse_to_world(2).collider.is_in_group("enemy"):
			emit_signal("enemy_under_mouse", raycast_mouse_to_world(2).collider)
		elif raycast_mouse_to_world(2).collider.is_in_group("npc"):
			emit_signal("npc_under_mouse", raycast_mouse_to_world(2).collider)
		else:
			emit_signal("enemy_not_under_mouse")
			emit_signal("npc_not_under_mouse")
	elif raycast_mouse_to_world(20):
		emit_signal("arrow_under_mouse", raycast_mouse_to_world(20).collider)
	elif raycast_mouse_to_world(6):
		emit_signal("book_under_mouse", raycast_mouse_to_world(6).collider)
	else:
		emit_signal("book_not_under_mouse")
		emit_signal("arrow_not_under_mouse")
		emit_signal("enemy_not_under_mouse")
		emit_signal("npc_not_under_mouse")
	if get_tree().get_nodes_in_group("player").size() > 0:
		translation = get_tree().get_nodes_in_group("player")[0].get_translation() + offset_from_player
	if raycast_mouse_to_world(1):
		emit_signal("mousetrack", raycast_mouse_to_world(1).position)
		#get_node("../Indicator")._move_to_mouse(raycast_mouse_to_world(1).position)

func raycast_mouse_to_world(collision_layer):
	collision_layer = collision_layer - 1
	var a = 1
	for i in range (collision_layer):
		a*=2
	collision_layer = a
	var from = project_ray_origin(get_viewport().get_mouse_position())
	var to = from + project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], collision_layer)
	return result


func _on_TurnOrderManager_next_actor(actor):
	turn_actor = actor.get_name()


func _on_PlayerSpawner_playerspawned():
	var p = get_tree().get_nodes_in_group("player")[0]
	connect("moveclick", p, "_on_Camera_moveclick")
	connect("npc_clicked", p, "_on_Camera_npc_clicked")
	connect("bookclicked", p, "book_clicked")
