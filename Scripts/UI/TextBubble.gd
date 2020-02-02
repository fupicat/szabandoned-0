extends CanvasLayer

signal ended_line

var skip = false

func _ready():
    think('Hello!')
    yield($".", "ended_line")
    think('Howaya?')
    yield($".", "ended_line")
    print('end')

func _input(event):
    if event.is_action_pressed("action"):
        if $Control/Text.visible_characters == -1:
            emit_signal("ended_line")
            return
        skip = true

func think(var message := 'Error: Could not load text.'):
    $Control/Background.texture = load("res://Art/GUI/WhiteGradient.tres")
    $Control/Text.bbcode_text = message
    $Control/Text.visible_characters = 0
    next_char()

func next_char(var timer := 0.05):
    if $Control/Text.visible_characters == len($Control/Text.text) or skip:
        $Control/Text.visible_characters = -1
        return
    yield(get_tree().create_timer(timer, false), "timeout")
    $Control/Text.visible_characters += 1
    next_char()
