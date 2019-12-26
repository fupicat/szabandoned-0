extends Node2D

var old_xy = Vector2(0, 0)
var old_col = null
var edit_mode = false
var obj = null
var place_up = true
var place_down = true

func _ready():
    $Player/Camera2D.limit_left = -3500
    $Player/Camera2D.limit_right = 3500
    $Player/Camera2D.limit_bottom = 4720

func _physics_process(delta):
    if edit_mode and !place_down:
        $Player.position.y += 10
    if edit_mode and !place_up:
        $Player.position.y -= 10

func switch_edit_mode(): # Returns true if switched.
    if edit_mode:
        var cant = false
        for node in get_tree().get_nodes_in_group("Interactable"):
            if !node.place():
                cant = true
        if cant:
            print("One of the items could not be placed.")
        else:
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
        for node in get_tree().get_nodes_in_group("Interactable"):
            node.get_node("Col").disabled = true
    return true

func add_placeable(var scene, var collision = true):
    $Player/CollisionShape2D.disabled = false
    obj = scene.instance()
    add_child(obj)
    obj.get_node("Col").disabled = true
    if collision:
        $Player/CollisionShape2D.shape = obj.get_node("Col").shape
    else:
        $Player/CollisionShape2D.disabled = true
    obj.move = true

func _on_Placent_body_entered(body):
    if body == $Player and edit_mode:
        place_down = false

func _on_Placent_body_exited(body):
    if body == $Player and edit_mode:
        place_down = true

func _on_PlacentUp_body_entered(body):
    if body == $Player and edit_mode:
        place_up = false

func _on_PlacentUp_body_exited(body):
    if body == $Player and edit_mode:
        place_up = true