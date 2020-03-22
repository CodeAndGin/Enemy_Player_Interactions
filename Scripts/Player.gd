extends KinematicBody

var path = []
var path_ind = 0
const move_speed = 5
const move_dist = 10

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

var dialogue
var dialogue_iter = 0
var all_dialogue_received = false
signal dialogue_received_from_json(array_length)
signal send_dialogue(text)
signal dialogue_sent
signal dialogue_amount_sent(a)


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
		
func check_dist_to_enemy():
	if (target_enemy.get_ref().get_translation() - get_translation()).length() < 2:
		enemy_in_range = true
	else:
		enemy_in_range = false

func stop_move_on_enemy_approach(enemy):
	if (enemy.get_ref().get_translation() - get_translation()).length() < 2:
		path = []
		path_ind = 0

func detarget_enemy():
	target_enemy = null

func dist_from_prev_frame():
	dist_tracker_vec = position_tracker - get_translation()
	return dist_tracker_vec.length()
 
func move_to(target_pos):
	target_enemy = null
	if turn:
		path = nav.get_simple_path(global_transform.origin, target_pos)
		path_ind = 0

func move_to_enemy(enemy):
	if turn:
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
		path = []
		path_ind = 0
		target_enemy = null
		get_parent().get_parent().signal_next_actor()

func parse_dialogue():
	var file = File.new()
	file.open("res://JSON/testDialogue.json", File.READ)
	var data = parse_json(file.get_as_text())
	for actor in data.actors :
		if actor.name == "player":
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


func _on_TurnOrderManager_next_actor(actor):
	if actor == self:
		turn_signal_receiver()


func _on_NPC_dialogue_received_from_json(array_length):
	parse_dialogue()


func _on_NPC_dialogue_sent():
	if dialogue_iter != dialogue.size():
		all_dialogue_received = false
		sending_dialogue()
	elif not all_dialogue_received:
		emit_signal("dialogue_amount_sent", dialogue.size())
		emit_signal("dialogue_sent")
	else:
		pass


func _on_DialogueBox_all_text_received():
	all_dialogue_received = true
