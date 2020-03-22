extends Camera

const ray_length = 1000

signal enemy_under_mouse(target)
signal enemy_not_under_mouse

signal npc_under_mouse(target)
signal npc_not_under_mouse

signal npc_clicked(target)

 
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if raycast_mouse_to_world(2):
			if raycast_mouse_to_world(2).collider.is_in_group("enemy"):
				if get_node("../TurnOrderManager/Navigation/Player")._dist_check(raycast_mouse_to_world(1).position):
					get_tree().call_group("player", "move_to_enemy", raycast_mouse_to_world(2).collider)
			elif raycast_mouse_to_world(2).collider.is_in_group("npc"):
				emit_signal("npc_clicked", raycast_mouse_to_world(2).collider)
		elif raycast_mouse_to_world(1):
			if get_node("../TurnOrderManager/Navigation/Player")._dist_check(raycast_mouse_to_world(1).position):
				get_tree().call_group("player", "move_to", raycast_mouse_to_world(1).position)

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
	else:
		emit_signal("enemy_not_under_mouse")
		emit_signal("npc_not_under_mouse")
	
	if raycast_mouse_to_world(1):
		get_node("../Indicator")._move_to_mouse(raycast_mouse_to_world(1).position)

func raycast_mouse_to_world(collision_layer):
	var from = project_ray_origin(get_viewport().get_mouse_position())
	var to = from + project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], collision_layer)
	return result
