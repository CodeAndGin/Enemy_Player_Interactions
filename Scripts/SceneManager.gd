extends Spatial

export(PackedScene) var classroom
export(PackedScene) var courtyard
export(PackedScene) var courtyardcombat
export(PackedScene) var library
export(PackedScene) var testscene
export(PackedScene) var title_screen

signal spawnplayer(from, to)
signal fade
signal unfade

export var conversationJSONname = "res://JSON/"

signal conversation(name)

var book_found = false

func _ready():
	add_child(title_screen.instance())


func _on_Door_scenechangesignal(scene, from):
	match scene:
		"Classroom":
			load_new_scene(classroom, from, "Classroom")
		"Courtyard":
			if book_found:
				load_new_scene(courtyardcombat, from, "Courtyard")
			else:
				load_new_scene(courtyard, from, "Courtyard")
		"Library":
			load_new_scene(library, from, "Library")
		"Test":
			load_new_scene(testscene, from, "Test")

func On_Play_Pressed():
	print("ButtonPressed")
	load_new_scene(classroom, "Title", "Classroom")


func load_new_scene(scene, from, to):
	emit_signal("fade")
	yield(get_tree().create_timer(2), "timeout")
	get_child(2).queue_free()
	remove_child(get_child(2))
	add_child(scene.instance())
	if to == "Library" and book_found:
		get_child(2).find_node("BookReal3").queue_free()
	connect("spawnplayer", get_child(2).find_node("PlayerSpawner"), "_spawn_player")
	yield(get_tree().create_timer(0.05), "timeout")
	emit_signal("spawnplayer", from, to)
	if from == "Title":
		emit_signal("conversation", conversationJSONname)
		yield($DialogueBox, "text_cleared")
	emit_signal("unfade")


func _on_book_clicked():
	book_found = true
