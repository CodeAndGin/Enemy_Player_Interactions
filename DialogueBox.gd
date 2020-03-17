extends Control

var text = ["This is some test dialogue", "This is another line of test dialogue"]

var dialogueIter = 0
var dialogueSent = false
var dialogueSpeed = 0.05
var buffEnd = false

onready var textInterface = $Panel/TextInterfaceEngine

func _ready():
	pass

func _process(delta):
	textInterface.set_state(1)
	dialogueIter %= 2
	if !dialogueSent:
		textInterface.buff_text(text[dialogueIter], dialogueSpeed)
		dialogueSent = true
		buffEnd = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if buffEnd:
			textInterface.clear_text()
			dialogueIter += 1
			dialogueSent = false
		else:
			textInterface.set_buff_speed(0)

func _on_TextInterfaceEngine_buff_end():
	buffEnd = true
