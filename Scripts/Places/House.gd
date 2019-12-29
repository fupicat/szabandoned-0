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

func _input(event):
    if (event.is_action_pressed("action") and edit_mode) or event.is_action_pressed("mode"):
        switch_edit_mode()
    if event.is_action_pressed('ui_page_up'):
        var tocando = []
        for node in get_tree().get_nodes_in_group('Interactable'):
            if node.on_me:
                tocando.append(node)
        var movethis = null
        for node in tocando:
            if movethis == null or node.z_index > movethis.z_index:
                movethis = node
        
        switch_edit_mode()
        movethis.move = true

func switch_edit_mode(): # Returns true if switched.
    if edit_mode:
        var cant = false
        for node in get_tree().get_nodes_in_group("Interactable"):
            if !node.place():
                cant = true
        if cant:
            print("One of the items could not be placed.")
            return false
        
        $HouseUI/UI/Mode.text = "Edit Mode"
        $HouseUI/UI/Items.hide()
        edit_mode = false
        $Player.global_position = old_xy
        $Player/CollisionShape2D.shape = old_col
        $Player.show()
        $Player/CollisionShape2D.disabled = false
        $Player.position = Vector2(3195, 1522)
    else:
        $HouseUI/UI/Mode.text = "Accept"
        $HouseUI/UI/Items.show()
        edit_mode = true
        old_xy = $Player.global_position
        old_col = $Player/CollisionShape2D.shape
        $Player.hide()
        $HouseUI/UI/Items.show()
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
    $HouseUI/UI/Items.hide()

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