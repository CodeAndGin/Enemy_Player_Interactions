extends KinematicBody

var path = []
var path_ind = 0
const move_speed = 5
const move_dist = 10

onready var nav = get_parent()

var position_tracker : Vector3
var dist_tracker_vec
var dist_tracker_float

var turn = false


func _ready():
	add_to_group("player")
	dist_tracker_float = move_dist
	position_tracker = get_translation()
 
func _physics_process(delta):
	if turn:
		move()
		position_tracker = get_translation()
		turn_over()

func move():
	if dist_tracker_float > 0:
		if path_ind < path.size():
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
		dist_tracker_float -= dist_from_prev_frame()


func dist_from_prev_frame():
	dist_tracker_vec = position_tracker - get_translation()
	return dist_tracker_vec.length()
 
func move_to(target_pos):
	if turn:
		path = nav.get_simple_path(global_transform.origin, target_pos)
		path_ind = 0

func _dist_check(target_pos):
	if translation.distance_to(target_pos) > move_dist:
		return false
	return true

func turn_signal_receiver():
	turn = true
	dist_tracker_float = move_dist

func turn_over():
	if dist_tracker_float <= 0 and turn:
		turn = false
		path = []
		path_ind = 0
		get_parent().get_parent().signal_next_actor()
