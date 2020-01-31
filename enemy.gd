extends KinematicBody

var mouse_detected = false

var turn = false
var turn_move_path_found = false

var path = []
var path_ind = 0
const move_speed = 5
const move_dist = 10

var position_tracker : Vector3
var dist_tracker_vec
var dist_tracker_float

var player_in_range = false

onready var nav = get_parent()

func _ready():
	add_to_group("enemy")
	dist_tracker_float = move_dist
	position_tracker = get_translation()

func _process(delta):
	control_outline()
	if turn:
		move_to(find_player())
		move()
		position_tracker = get_translation()
		turn_over()

func control_outline():
	var outline = $MeshInstance.mesh.surface_get_material(0).get_next_pass()
	outline.params_grow = mouse_detected
	if turn:
		outline.params_grow = turn

func move():
	if dist_tracker_float > 0 and turn_move_path_found:
		if path_ind < path.size():
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
		dist_tracker_float -= dist_from_prev_frame()

func move_to(target_pos):
	if !turn_move_path_found:
		print("finding path to player: %s" % target_pos)
		path = nav.get_simple_path(global_transform.origin, target_pos)
		path_ind = 0
		turn_move_path_found = true
	
	if (find_player() - get_translation()).length() < 2:
		path = []
		path_ind = 0
		player_in_range = true
		dist_tracker_float = 0
	else:
		player_in_range = false

func attack():
	pass

func find_player():
	var player = get_tree().get_nodes_in_group("player")
	return player[0].get_translation()

func dist_from_prev_frame():
	dist_tracker_vec = position_tracker - get_translation()
	return dist_tracker_vec.length()

func turn_signal_receiver():
	turn = true
	dist_tracker_float = move_dist

func turn_over():
	if dist_tracker_float <= 0 and turn:
		turn = false
		turn_move_path_found = false
		get_parent().get_parent().signal_next_actor()

func _on_Camera_enemy_under_mouse():
	mouse_detected = true

func _on_Camera_enemy_not_under_mouse():
	mouse_detected = false
