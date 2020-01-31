extends Node2D

var old_xy = Vector2(0, 0)
var old_col = null
var edit_mode = false
var move_mode = false
var delete_mode = false
var obj = null
var place_up = true
var place_down = true

var on_UI = false

func _ready():
    $Player/Scrat.scale.x = -1
    $Player/Camera2D.limit_left = -3500
    $Player/Camera2D.limit_right = 3500
    $Player/Camera2D.limit_bottom = 4720
    if Global.house != []:
        for item in Global.house:
            var inst = load(item['file']).instance()
            add_child(inst)
            
            var posxy = item['pos'].split(' ')
            inst.global_position.x = float(posxy[0])
            inst.global_position.y = float(posxy[1])
            
            var scalexy = item['scale'].split(' ')
            inst.scale.x = float(scalexy[0])
            inst.scale.y = float(scalexy[1])
            
            inst.get_node('Sprite').texture = load(item['sprite'])
            inst.update_z()

func _physics_process(_delta):
    if edit_mode and !place_down:
        $Player.position.y += 10
    if edit_mode and !place_up:
        $Player.position.y -= 10

func _input(event):
    if event.is_action_pressed("action") and edit_mode:
        if on_UI:
            return
        if move_mode:
            move_obj()
            return
        if delete_mode:
            delete_obj()
            return
        switch_edit_mode()
        

func switch_edit_mode(): # Returns true if switched.
    $Player.target = null
    if edit_mode:
        $Player.can_walk = true
        var cant = false
        for node in get_tree().get_nodes_in_group("Interactable"):
            if !node.move:
                node.get_node("Col").disabled = false
                continue
            if !node.place():
                cant = true
        if cant:
            print("One of the items could not be placed.")
            return false
        
        $HouseUI/UI/Mode.text = "Edit"
        $HouseUI/UI/Items.hide()
        edit_mode = false
        $Player.global_position = old_xy
        $Player/CollisionShape2D.shape = old_col
        $Player.show()
        $Player/CollisionShape2D.disabled = false
        $Player.position = Vector2(3195, 1522)
        move_mode = false
        delete_mode = false
        $HouseUI/UI/Select.hide()
    else:
        $Player.can_walk = true
        $HouseUI/UI/Mode.text = "Place"
        if delete_mode:
            $HouseUI/UI/Mode.text = "Back"
        $HouseUI/UI/Items.show()
        edit_mode = true
        old_xy = $Player.global_position
        old_col = $Player/CollisionShape2D.shape
        $Player.hide()
        $HouseUI/UI/Items.show()
        for node in get_tree().get_nodes_in_group("Interactable"):
            node.get_node("Col").disabled = true
        
        if move_mode or delete_mode:
            $HouseUI/UI/Items.hide()
            $Player.show()
        $HouseUI/UI/Select.text = 'Move this'
        if move_mode or delete_mode:
            $HouseUI/UI/Select.show()
            if delete_mode:
                $HouseUI/UI/Select.text = 'Delete this'
            
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

func move_obj():
    var tocando = []
    for node in get_tree().get_nodes_in_group('Interactable'):
        if node.on_me:
            tocando.append(node)
    var movethis = null
    for node in tocando:
        if movethis == null or node.z_index > movethis.z_index:
            movethis = node
    
    if movethis != null:
        $Player.hide()
        move_mode = false
        movethis.move = true

func delete_obj():
    var tocando = []
    for node in get_tree().get_nodes_in_group('Interactable'):
        if node.on_me:
            tocando.append(node)
    var delthis = null
    for node in tocando:
        if delthis == null or node.z_index > delthis.z_index:
            delthis = node
    if delthis != null:
        delthis.queue_free()

func _on_Exit_body_entered(body):
    if body == $Player:
        $Player.can_walk = false
        Global.transition_scene('res://Scenes/Places/Town.tscn')

# Actions

func Rotate(var upper):
    $Player/CollisionShape2D.disabled = false
    $Player.disconnect('got_there', $".", 'Rotate')
    
    var path = upper.get_node('Sprite').texture.resource_path
    if path.ends_with('Side.png'):
        path = path.replace('Side.png', '')
        if upper.scale.x > 0:
            upper.get_node('Sprite').texture = load(path + 'Front.png')
        if upper.scale.x < 0:
            upper.scale.x = abs(upper.scale.x)
            upper.get_node('Sprite').texture = load(path + 'Back.png')
    elif path.ends_with('Front.png'):
        path = path.replace('Front.png', '')
        upper.scale.x = abs(upper.scale.x) * -1
        upper.get_node('Sprite').texture = load(path + 'Side.png')
    elif path.ends_with('Back.png'):
        path = path.replace('Back.png', '')
        upper.scale.x = abs(upper.scale.x)
        upper.get_node('Sprite').texture = load(path + 'Side.png')
    else:
        upper.scale.x = upper.scale.x * -1
    $Player.can_walk = true

func Change(var upper):
    $Player/CollisionShape2D.disabled = false
    $Player.disconnect('got_there', $".", 'Change')
    var i = 0
    var sprites = upper.xtra_sprites
    for item in sprites:
        
        var build_path = 'res://Art/Placeables/' + item + '.png'
        
        if build_path == upper.get_node('Sprite').texture.resource_path:
            
            var what = 'res://Art/Placeables/' + sprites[0] + '.png'
            if len(sprites) > i + 1:
                what = 'res://Art/Placeables/' + sprites[i + 1] + '.png'
                
            upper.get_node('Sprite').texture = load(what)
            break
            
        i += 1
    $Player.can_walk = true
