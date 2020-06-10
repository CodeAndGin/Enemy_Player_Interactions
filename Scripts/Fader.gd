extends Sprite

var fade_in = false
var fade_out = false

func _ready():
	pass


func _physics_process(delta):
	if fade_in:
		texture.gradient.colors[0].a += 0.01
		if texture.gradient.colors[0].a > 1:
			fade_in = false
	if fade_out:
		texture.gradient.colors[0].a -= 0.01
		if texture.gradient.colors[0].a < 0:
			fade_out = false

func _on_SceneManager_fade():
	fade_in = true
	fade_out = false


func _on_SceneManager_unfade():
	fade_out = true
	fade_in = false
