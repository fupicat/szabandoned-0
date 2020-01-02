extends Node2D

var active = ''
var select = false
var phantom_select = false
var the_obj = null
var the_actions = []

func menu(var object, var actions):
    the_obj = object
    the_actions = actions
    get_parent().can_walk = false
    var i = 0
    var file = File.new()
    for node in $Menu.get_children():
        node.texture_normal = null
    for act in actions:
        var texture = load('res://Art/GUI/Use.png')
        if file.file_exists('res://Art/GUI/' + act + '.png'):
            texture = load('res://Art/GUI/' + act + '.png')
        $Menu.get_child(i).texture_normal = texture
        i+=1
    $Anim.stop()
    active = ''
    select = true
    phantom_select = true
    $Anim.play("In")

func _process(delta):
    if select == true:
        for node in $Menu.get_children():
            node.modulate = Color(1, 1, 1)
        var lr = ''
        var ud = ''
        if Input.is_action_pressed('left') and !Input.is_action_pressed("right"):
            lr = 'L'
        if Input.is_action_pressed("right") and !Input.is_action_pressed('left'):
            lr = 'R'
        if Input.is_action_pressed("up") and !Input.is_action_pressed("down"):
            ud = 'U'
        if Input.is_action_pressed("down") and !Input.is_action_pressed("up"):
            ud = 'D'
        active = lr + ud
    else:
        active = ''
    if active != '':
        get_node('Menu/' + active).modulate = Color(0.215686, 0.219608, 1)

func _input(event):
    if event.is_action_pressed("action") and select:
        if active != '':
            get_parent().get_parent().call(the_actions[get_node('Menu/' + active).get_position_in_parent()], the_obj)
        get_parent().can_walk = true
        select = false
        hide()
        $Timer.start()

func _on_Timer_timeout():
    phantom_select = false
