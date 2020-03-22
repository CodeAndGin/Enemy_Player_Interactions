extends Control

var text = []
var textreceived = 0
signal all_text_received

var dialogueIter = 0
var dialogueSent = false
var dialogueSpeed = 0.05
var buffEnd = false

onready var textInterface = $Panel/TextInterfaceEngine

func _ready():
	pass

func _process(delta):
	textInterface.set_state(1)
	if text.size() > 0:
		dialogueIter %= text.size()
	if text.size() > 0:
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


func _on_Player_send_dialogue(_text):
	text.append(text)


func _on_NPC_send_dialogue(_text):
	text.append(text)


func _on_Player_dialogue_received_from_json(array_length):
	pass


func _on_Player_dialogue_amount_sent(a):
	textreceived += a
	if textreceived == text.size():
		emit_signal("all_text_received")


func _on_NPC_dialogue_amount_sent(a):
	textreceived += a
	if textreceived == text.size():
		emit_signal("all_text_received")
