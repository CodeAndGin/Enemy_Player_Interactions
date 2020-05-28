extends ImmediateGeometry

var draw_path = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var begin = Vector3()
var end = Vector3()
var path = []
export var m : SpatialMaterial
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_path()

func _update_path():
	var p = get_node("/root/Class/TurnOrderManager/Navigation/Player").get_path()
	path = Array(p) # Vector3 array too complex to use, convert to regular array.
	path.invert()
	set_process(true)
	
	if draw_path:
		var im = self
		im.set_material_override(m)
		im.clear()
		im.begin(Mesh.PRIMITIVE_POINTS, null)
		im.add_vertex(begin)
		im.add_vertex(end)
		im.end()
		im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		for x in p:
			im.add_vertex(x)
		im.end()
