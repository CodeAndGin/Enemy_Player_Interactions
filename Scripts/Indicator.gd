extends MeshInstance

func _ready():
	pass

func _physics_process(delta):
	color_shift_if_dist_is_too_high()

func _move_to_mouse(_pos):
	_pos += Vector3(0,0,0)
	translation = _pos

func color_shift_if_dist_is_too_high():
	if !get_node("../Navigation/Player")._dist_check(translation):
		get_surface_material(0).albedo_color = Color(1,0,0,1) #red
	else:
		get_surface_material(0).albedo_color = Color(0,0,1,1) #blue
