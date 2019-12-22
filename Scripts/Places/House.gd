extends Node2D

var old_xy = Vector2(0, 0)
var old_col = null
var edit_mode = false

func _ready():
    $Player/Camera2D.limit_left = -3500
    $Player/Camera2D.limit_right = 3500
    $Player/Camera2D.limit_bottom = 4720

func _input(event):
    if event.is_action_pressed("1"):
        switch_edit_mode()
    if event.is_action_pressed("2"):
        add_placeable(load("res://Scenes/Placeables/SmallRoom.tscn"))

func switch_edit_mode():
    if edit_mode:
        for node in get_tree().get_nodes_in_group("Interactable"):
            if node.move:
                node.move = false
                node.get_node("Col").disabled = false
        edit_mode = false
        $Player.global_position = old_xy
        $Player/CollisionShape2D.shape = old_col
        $Player.show()
        $Player/CollisionShape2D.disabled = false
    else:
        edit_mode = true
        old_xy = $Player.global_position
        old_col = $Player/CollisionShape2D.shape
        $Player.hide()

func add_placeable(var scene):
    var obj = scene.instance()
    add_child(obj)
    obj.get_node("Col").disabled = true
    $Player/CollisionShape2D.shape = obj.get_node("Col").shape
    obj.move = true