extends Spatial

export(PackedScene) var classroom
export(PackedScene) var courtyard
export(PackedScene) var library
export(PackedScene) var testscene
export(PackedScene) var title_screen

signal spawnplayer(from, to)

func _ready():
	add_child(title_screen.instance())


func _on_Door_scenechangesignal(scene, from):
	match scene:
		"Classroom":
			load_new_scene(classroom, from, "Classroom")
		"Courtyard":
			load_new_scene(courtyard, from, "Courtyard")
		"Library":
			load_new_scene(library, from, "Library")
		"Test":
			load_new_scene(testscene, from, "Test")

func On_Play_Pressed():
	print("ButtonPressed")
	load_new_scene(classroom, "Title", "Classroom")


func load_new_scene(scene, from, to):
	get_child(0).queue_free()
	remove_child(get_child(0))
	add_child(scene.instance())
	connect("spawnplayer", get_child(0).find_node("PlayerSpawner"), "_spawn_player")
	yield(get_tree().create_timer(0.05), "timeout")
	emit_signal("spawnplayer", from, to)
