extends Spatial

onready var mat = preload("res://Materials/Book.material").duplicate(true)

var colors = [Color(0.2, 0.4, 0), 
			  Color(0.6, 0, 0.2), 
			  Color(0.4, 0, 0.4), 
			  Color(0.4, 0.2, 0)]

func _ready():
	randomize()
	$MeshInstance.mesh = $MeshInstance.mesh.duplicate(true)
	$MeshInstance.mesh.surface_set_material(0, mat)
	mat.set_albedo(colors[randi()%colors.size()])
