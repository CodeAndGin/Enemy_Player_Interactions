extends TextureButton

signal play_pressed

func _ready():
	connect("play_pressed", get_node("/root/SceneManager"), "On_Play_Pressed")



func _on_Play_pressed():
	emit_signal("play_pressed")
