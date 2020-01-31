extends Spatial

var list_of_actors = []
var current_actor = 0

func _ready():
	list_of_actors += get_tree().get_nodes_in_group("player")
	list_of_actors += get_tree().get_nodes_in_group("enemy")
	sort_actors()
	signal_next_actor()


func _process(delta):
	pass

func next_turn_iter():
	current_actor += 1
	current_actor %= list_of_actors.size()

func signal_next_actor():
	list_of_actors[current_actor].turn_signal_receiver()
	print(current_actor)
	next_turn_iter()

func sort_actors():
	pass #TODO: Priority order of speed?

func reset_actor_list():
	list_of_actors = get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("enemy")
