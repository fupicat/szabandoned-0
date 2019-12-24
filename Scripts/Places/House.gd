extends Node2D

#Talvez: Criar area2D com a shape do obj e ver se overlapa. Se overlapeando.x > eu.x, eu.x -= 1 até não overlapear sacou?

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

func _input(event):
    if event.is_action_pressed("1"):
        switch_edit_mode()
    if event.is_action_pressed("2"):
        add_placeable(load("res://Scenes/Placeables/SmallRoom.tscn"))

func switch_edit_mode(): # Returns true if switched.
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
        for node in get_tree().get_nodes_in_group("Interactable"):
            node.get_node("Col").disabled = true
    return true

func add_placeable(var scene):
    obj = scene.instance()
    add_child(obj)
    obj.get_node("Col").disabled = true
    $Player/CollisionShape2D.shape = obj.get_node("Col").shape
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