extends CanvasLayer

signal ended_line

var skip = false

func _input(event):
    if event.is_action_pressed("action"):
        if $Control/Text.visible_characters == -1:
            emit_signal("ended_line")
            return
        skip = true

func think(var message := 'Error: Could not load text.'):
    var here = get_tree().current_scene
    Global.focus_camera(here.get_node('Player'))
    
    $Control/Name.bbcode_text = ''
    $Control/Background.texture = load("res://Art/GUI/WhiteGradient.tres")
    $Control/Text.bbcode_text = message
    $Control/Text.visible_characters = 0
    skip = false
    next_char()

func speak(var message := 'Error: Could not load text.',
        var name = 'error',
        var obj = null):
    if obj != null:
        Global.focus_camera(obj)
    
    $Control/Name.bbcode_text = name
    $Control/Background.texture = load("res://Art/GUI/BlackGradient.tres")
    $Control/Text.bbcode_text = message
    $Control/Text.visible_characters = 0
    skip = false
    next_char()

func next_char(var timer := 0.05):
    if $Control/Text.visible_characters == len($Control/Text.text) or skip:
        $Control/Text.visible_characters = -1
        return
    yield(get_tree().create_timer(timer, false), "timeout")
    $Control/Text.visible_characters += 1
    next_char()
