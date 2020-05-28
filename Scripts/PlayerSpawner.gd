extends Spatial

onready var nav = get_parent() #gotta instance player as child of nav else itll break
onready var player = preload("res://Scenes/player.tscn")
var children

export var scale_offset = 1.0
export var y_offset = 0.0

signal playerspawned

func _ready():
	children = get_children()
	#Children per scene:
		#Class:
			#0: DeskSpawn
			#1: DoorSpawn
		#Courtyard:
			#0: LibrarySpawn
			#1: ClassroomSpawn
		#Library:
			#0: DoorSpawn

func _process(delta):
	pass

func _spawn_player(from, to): #TODO signal from scene controller to here
	
	match to:
		"Classroom":
			match from:
				"Title":
					spawn(children[0], "Classroom") #spawn at desk
				"Courtyard":
					spawn(children[1], "Classroom") #spawn at door
		"Courtyard":
			match from:
				"Classroom":
					print("TestPassed")
					spawn(children[1], "Courtyard")
				"Library":
					spawn(children[0], "Courtyard")
		"Library":
			spawn(children[0], "Library")

func spawn(location_node, area): #COURTYARD: SCALE BY 
	var p = player.instance()
	nav.add_child(p)
	p.translation = location_node.get_translation() + Vector3(0,y_offset,0)
	#Totally messed up the scale between scenes so this is the fastest way to make it look reasonable
	p.scale *= scale_offset
	p.move_speed *= scale_offset
	p.move_dist *= scale_offset
	emit_signal("playerspawned")
