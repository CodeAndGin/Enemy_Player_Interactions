extends KinematicBody

var path = []
var path_ind = 0
var move_speed = 5
var move_dist = 10

onready var nav = get_parent()

var position_tracker : Vector3
var dist_tracker_vec
var dist_tracker_float

const MAX_HEALTH = 100
var health

const ATTACK_POWER = 10

var turn = false

var target_enemy = null
var enemy_in_range = false

var is_moving = false
var is_in_dialogue = false
var is_offset = false #some of the poses have slightly different z values, so rather than fix those poses im just offsetting the Z


func _ready():
	add_to_group("player")
	dist_tracker_float = move_dist
	position_tracker = get_translation()
	health = MAX_HEALTH
 
func _physics_process(delta):
	if turn:
		if target_enemy != null:
			if target_enemy.get_ref():
				check_dist_to_enemy()
				if enemy_in_range:
					stop_move_on_enemy_approach(target_enemy)
			else:
				enemy_in_range = false
		if not is_in_dialogue:
			move()
		else:
			$Person/AnimationPlayer.play("Chatting") #fix location offset
			if not is_offset:
				translate(Vector3(0,1,0))
				is_offset = true
		if not is_moving and not is_in_dialogue:
			$Person/AnimationPlayer.play("Idle")
			if is_offset:
				translate(Vector3(0,-1,0))
				is_offset = false
		position_tracker = get_translation()
		turn_over()
	else:
		$Person/AnimationPlayer.play("Idle")

func move():
	if dist_tracker_float > 0:
		if path_ind < path.size():
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
				var angle = move_vec.angle_to(Vector3(1, 0, 0))
				if move_vec.z >= 0 :
					angle = 2*PI - angle
				rotation.y = angle+PI/2
				$Person/AnimationPlayer.play("Walk")
				is_moving = true
		else:
			is_moving = false
		dist_tracker_float -= dist_from_prev_frame()
		
func check_dist_to_enemy():
	if (target_enemy.get_ref().get_translation() - get_translation()).length() < 2:
		enemy_in_range = true
	else:
		enemy_in_range = false

func stop_move_on_enemy_approach(enemy):
	if (enemy.get_ref().get_translation() - get_translation()).length() < 2:
		clear_move_path()

func detarget_enemy():
	target_enemy = null

func dist_from_prev_frame():
	dist_tracker_vec = position_tracker - get_translation()
	return dist_tracker_vec.length()
 
func move_to(target_pos):
	target_enemy = null
	if turn and not is_in_dialogue:
		#path = nav.get_simple_path(global_transform.origin, target_pos)
		path = nav.get_simple_path(global_transform.origin, target_pos)
		path_ind = 0

func move_to_enemy(enemy):
	if turn and not is_in_dialogue:
		if enemy_in_range:
			attack_target(enemy)
			dist_tracker_float -= 2
			pass
		path = nav.get_simple_path(global_transform.origin, enemy.get_translation())
		path_ind = 0
		target_enemy = weakref(enemy)

func attack_target(enemy):
	var damage = rand_range(ATTACK_POWER*0.9, ATTACK_POWER*1.1)
	enemy.take_hit(damage)

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
		clear_move_path()
		target_enemy = null
		get_parent().get_parent().signal_next_actor()

func get_path():
	return path

func _on_TurnOrderManager_next_actor(actor):
	if actor == self:
		turn_signal_receiver()


func _on_DialogueBox_text_cleared():
	is_in_dialogue = false


func _on_Camera_npc_clicked(target):
	var angle = (target.get_translation() - global_transform.origin).angle_to(Vector3(1, 0, 0))
#	if target.get_translation().z >= 0 :
#		angle = 2*PI + angle
	rotation.y = angle+PI/2
	is_in_dialogue = true
	clear_move_path()

func clear_move_path():
	path = []
	path_ind = 0


func _on_Camera_moveclick(target):
	move_to(target)
