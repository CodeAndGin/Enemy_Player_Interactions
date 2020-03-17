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

var MAX_HEALTH = 20
var health
var defence = 3

onready var nav = get_parent()
onready var camera = get_tree().get_root().get_camera()

signal death(actor)


func _ready():
	add_to_group("enemy")
	$MeshInstance.mesh = $MeshInstance.mesh.duplicate(true)
	$MeshInstance.mesh.surface_set_material(0, $MeshInstance.mesh.surface_get_material(0).duplicate(true))
	dist_tracker_float = move_dist
	position_tracker = get_translation()
	health = MAX_HEALTH
	$HealthBar.max_value = MAX_HEALTH
	$HealthBar.min_value = 0

func _process(delta):
	control_outline()
	update_health_bar()
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
#		print("finding path to player: %s" % target_pos)
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

func take_hit(damage):
	var damage_reduction = rand_range(defence*0.9, defence*1.1)
	take_damage(damage - damage_reduction)

func take_damage(damage):
	if damage > 0:
		health -= damage
	if health <= 0:
		death()

func update_health_bar():
	$HealthBar.value = health
	$HealthBar.rect_position = get_tree().get_root().get_camera().unproject_position(translation)
	$HealthBar.rect_position.x -= 55
	$HealthBar.rect_position.y -= 45

func death():
	get_tree().get_nodes_in_group("player")[0].detarget_enemy()
	emit_signal("death", self)
	queue_free()

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

func _on_Camera_enemy_under_mouse(target):
	if target.get_name() == get_name():
		mouse_detected = true
	else:
		mouse_detected = false

func _on_Camera_enemy_not_under_mouse():
	mouse_detected = false

func _on_TurnOrderManager_next_actor(actor):
	if actor == self:
		turn_signal_receiver()
