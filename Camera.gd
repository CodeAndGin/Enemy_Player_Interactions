extends Camera

const ray_length = 1000

signal enemy_under_mouse
signal enemy_not_under_mouse

 
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * ray_length
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [], 1)
		if result:
			if get_node("../TurnOrderManager/Navigation/Player")._dist_check(result.position):
				get_tree().call_group("player", "move_to", result.position)

func _process(delta):
	var from = project_ray_origin(get_viewport().get_mouse_position())
	var to = from + project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 1)
	if result:
		if result.collider.get_groups().size() != 0:
			for group in result.collider.get_groups():
				if group == "enemy":
					emit_signal("enemy_under_mouse")
		else:
			emit_signal("enemy_not_under_mouse")
		
		get_node("../Indicator")._move_to_mouse(result.position)