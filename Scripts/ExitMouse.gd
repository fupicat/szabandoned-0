extends Area2D

var on_me = false

func _ready():
    var _err = connect("mouse_entered", $".", 'mouse_in')
    _err = connect("mouse_exited", $".", 'mouse_out')
    add_to_group('Exit')

func mouse_in():
    on_me = true

func mouse_out():
    on_me = false