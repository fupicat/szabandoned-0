extends Node2D

var active = null
var select = false
var the_obj = null

func menu(var object, var actions):
    the_obj = object
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
    active = null
    select = true
    $Anim.play("In")
    