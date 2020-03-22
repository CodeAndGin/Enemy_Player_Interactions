extends Control

var text = []

var textNames = []

var dialogueIter = 0
var dialogueSent = false
var dialogueSpeed = 0.05
var buffEnd = false
var nameBuffEnd = false
var nameSent = false

onready var textInterface = $Panel/TextInterfaceEngine
onready var namesInterface = $Panel/Names

func _ready():
	pass

func _process(delta):
	textInterface.set_state(1)
	namesInterface.set_state(1)
	if text.size() == dialogueIter:
		text.clear()
		textNames.clear()
	if text.size() > 0:
		if !dialogueSent:
			textInterface.buff_text(text[dialogueIter], dialogueSpeed)
			dialogueSent = true
			buffEnd = false
		if !nameSent:
			namesInterface.buff_text(textNames[dialogueIter], 0)
			nameSent = true
			nameBuffEnd = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if buffEnd:
			textInterface.clear_text()
			namesInterface.clear_text()
			dialogueIter += 1
			dialogueSent = false
			nameSent = false
		else:
			textInterface.set_buff_speed(0)

func parse_dialogue(json):
	var dialogue = []
	var names = []
	dialogueIter = 0
	var file = File.new()
	file.open(json, File.READ)
	var data = parse_json(file.get_as_text())
	for actor in data.actors :
		for dialogues in actor.dialogue :
			names.append(0)
			dialogue.append(0) #should give an array [0,0,0,0......0] the same size as the amount of dialogue in the JSON
	for actor in data.actors :
		for i in range (actor.dialogue.size()):
			names[actor.indices[i]] = actor.name
			dialogue[actor.indices[i]] = actor.dialogue[i]
	text = dialogue
	textNames = names
	
	#Sending the new text
	namesInterface.clear_buffer()
	namesInterface.clear_text()
	textInterface.clear_buffer()
	textInterface.clear_text()
	textInterface.buff_text(text[dialogueIter], dialogueSpeed)
	namesInterface.buff_text(textNames[dialogueIter], 0)
	dialogueSent = true
	nameSent = true
	buffEnd = false
	nameBuffEnd = false
	

func _on_TextInterfaceEngine_buff_end():
	buffEnd = true

func _on_NPC_conversation(name):
	parse_dialogue(name)

func _on_Names_buff_end():
	nameBuffEnd = true
