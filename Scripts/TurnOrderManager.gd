extends Spatial

var list_of_actors = []
var current_actor = 0

signal next_actor(actor)

var startactorsignalled = false

func _ready():
	reset_actor_list_to_blank()
	sort_actors()
	signal_next_actor()
	

func reset_actor_list_to_blank():
	list_of_actors = []
	list_of_actors += get_tree().get_nodes_in_group("player")
	list_of_actors += get_tree().get_nodes_in_group("enemy")
	var list2 = []
	for actor in list_of_actors:
		list2.append(actor)
	list_of_actors = list2
	for actor in list_of_actors:
		connect("next_actor", actor, "_on_TurnOrderManager_next_actor")
	

func _process(delta):
	if startactorsignalled == false:
		reset_actor_list_to_blank()
		signal_next_actor()

func next_turn_iter():
	current_actor += 1
	current_actor %= list_of_actors.size()
#	if list_of_actors.size() == 1:
#		current_actor = 0

func signal_next_actor():
	if list_of_actors.size() > 0:
		emit_signal("next_actor", list_of_actors[current_actor])
		next_turn_iter()
		startactorsignalled = true

func sort_actors():
	pass #TODO: Priority order of speed?

func reset_actor_list(actor):
	list_of_actors.remove(list_of_actors.find(actor))
	current_actor %= list_of_actors.size()


func _on_KinematicBody_death(actor):
	reset_actor_list(actor)
