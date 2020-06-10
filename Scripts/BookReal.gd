extends Spatial

onready var sm = get_node("/root/SceneManager")
export var conversationJSONname = "res://JSON/"
signal clicked
export var correct_book = false
export var min_dist = 1.0
signal faraway(pos)
var connected_to_player = false
signal conversation(name)

func _ready():
	connect("clicked", sm, "_on_book_clicked")

func _process(delta):
	connect_to_player()

func _clicked(target):
	if check_dist_to_player():
		if target == $Cover/Pages/StaticBody or target == $Cover/StaticBody:
			
			emit_signal("conversation", conversationJSONname)
			if correct_book:
				emit_signal("clicked")
				queue_free()
	else:
		if target.get_name() == get_name():
			var d = (get_translation() - get_tree().get_nodes_in_group("player")[0].get_translation()).length()
			
			emit_signal("faraway", get_translation().linear_interpolate(get_tree().get_nodes_in_group("player")[0].get_translation(), min_dist/d-0.05))

func _mouse_under(target):
	if target == $Cover/Pages/StaticBody or target == $Cover/StaticBody:
		$Highlight.visible = true

func _mouse_not_under():
	$Highlight.visible = false

func check_dist_to_player():
	if (get_tree().get_nodes_in_group("player").size() < 1):
		return false
	if (get_translation() - get_tree().get_nodes_in_group("player")[0].get_translation()).length() < min_dist:
		return true
	return false

func connect_to_player():
	if connected_to_player == true:
		return
	if (get_tree().get_nodes_in_group("player").size() < 1):
		connected_to_player = false
	else:
		connect("faraway", get_tree().get_nodes_in_group("player")[0], "move_to")
		connected_to_player = true
		print(connected_to_player)
		

