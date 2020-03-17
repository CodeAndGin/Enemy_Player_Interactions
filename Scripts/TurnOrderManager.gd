extends Spatial

var list_of_actors = []
var current_actor = 0

signal next_actor(actor)

func _ready():
	list_of_actors += get_tree().get_nodes_in_group("player")
	list_of_actors += get_tree().get_nodes_in_group("enemy")
	var list2 = []
	for actor in list_of_actors:
		list2.append(actor)
	list_of_actors = list2
	sort_actors()
	signal_next_actor()


func _process(delta):
	pass

func next_turn_iter():
	current_actor += 1
	current_actor %= list_of_actors.size()
#	if list_of_actors.size() == 1:
#		current_actor = 0

func signal_next_actor():
	emit_signal("next_actor", list_of_actors[current_actor])
	next_turn_iter()

func sort_actors():
	pass #TODO: Priority order of speed?

func reset_actor_list(actor):
	list_of_actors.remove(list_of_actors.find(actor))
	current_actor %= list_of_actors.size()


func _on_KinematicBody_death(actor):
	reset_actor_list(actor)
