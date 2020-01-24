extends KinematicBody2D

var move = Vector2(0, 0)
const SPEED = 500
const RUNADD = 500
const SLIP = 0.20

var can_walk = true
var can_animate = true
var target = null

signal got_there

func _physics_process(_delta):
    if can_walk or target != null:
        #warning-ignore:NARROWING_CONVERSION
        z_index = global_position.y / 10
    var run = RUNADD * int(Input.is_action_pressed("run"))
    var ydir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
    move.y = lerp(move.y, (SPEED + run) * ydir, SLIP) * int(can_walk)
    
    var xdir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
    move.x = lerp(move.x, (SPEED + run) * xdir, SLIP) * int(can_walk)
    
    if xdir == 1:
        $Scrat.scale.x = 1
    elif xdir == -1:
        $Scrat.scale.x = -1
    if !can_walk:
        if move.x > 0:
            $Scrat.scale.x = 1
        else:
            $Scrat.scale.x = -1
    
    if target != null and !can_walk and !$Actions.visible:
        can_walk = false
        $Scrat.scale.x = 1
        if target.x < global_position.x:
            $Scrat.scale.x = -1
        move = (target - position).normalized() * (SPEED + RUNADD)
        if (target - position).length() < 20:
            move = Vector2(0, 0)
            global_position = target
            target = null
            can_walk = true
            emit_signal('got_there')
    
    move = move_and_slide(move)
    
    anim_walk()

func _input(event):
    if event.is_action_pressed("action") and !$Actions.phantom_select and can_walk:
        if get_tree().current_scene.filename.ends_with('House.tscn') and get_parent().edit_mode:
            return
        var inters = get_tree().get_nodes_in_group("Interactable")
        if len(inters) > 0:
            var onmes = []
            var upper = null
            for node in inters: # Get all interactable nodes and detect which ones the player is touching.
                if node.on_me:
                    onmes.append(node)
            var lookings = []
            for node in onmes: # Get all nodes the player is looking at.
                if ($Scrat.scale.x > 0 and node.global_position.x > global_position.x) or ($Scrat.scale.x < 0 and node.global_position.x < global_position.x) and !$Actions.visible:
                    lookings.append(node)
            if len(lookings) > 0:
                upper = lookings[0]
                for node in lookings:
                    if node.z_index > upper.z_index:
                        upper = node
                if len(upper.interact) > 0:
                    set_camera(upper)
                    $Actions.menu(upper, upper.interact)
    if event.is_action_pressed('run') and !can_animate and !can_walk:
        cancel_action()
    if event.is_action_pressed("click"):
        if get_tree().current_scene.filename.ends_with('House.tscn') and get_parent().edit_mode:
            target_mouse()
            return
        var inters = get_tree().get_nodes_in_group("Interactable")
        if len(inters) > 0:
            var onmes = []
            var upper = null
            for node in inters: # Get all interactable nodes and detect which ones the mouse is touching.
                if node.hover_me:
                    onmes.append(node)
            if len(onmes) > 0:
                upper = onmes[0]
                for node in onmes:
                    if node.z_index > upper.z_index:
                        upper = node
                if len(upper.interact) > 0 and can_animate:
                    set_camera(upper)
                    $Actions.menu(upper, upper.interact)
                else:
                    target_mouse()
            else:
                target_mouse()
    if event.is_action_pressed("down") or event.is_action_pressed("left") or event.is_action_pressed("right") or event.is_action_pressed("up"):
        if target != null and !$Actions.visible:
            target = null
            can_walk = true

func target_mouse():
    if ('on_UI' in get_parent()) and get_parent().on_UI:
        return
    if can_animate:
        can_walk = false
        target = get_global_mouse_position()
        for node in get_tree().get_nodes_in_group('Exit'):
            if node.on_me:
                target = node.global_position
    else:
        cancel_action()

func walk_to(var obj):
    if obj.has_node('IntPos'):
        $CollisionShape2D.disabled = true
        target = obj.get_node('IntPos').global_position

func anim_walk():
    if can_animate:
        if abs(move.x) < 30 and abs(move.y) < 30:
            $Scrat/Anim.play("Idle")
        else:
            if Input.is_action_pressed('run'):
                $Scrat/Anim.play('Run')
            else:
                $Scrat/Anim.play("Walk")

func animation(var name):
    can_animate = false
    $Scrat.scale.x = 1
    $Scrat/Anim.play(name)

func cancel_action():
    target = null
    can_animate = true
    can_walk = true
    $CollisionShape2D.disabled = false

func set_camera(var thing = null):
    if thing == null:
        $Camera2D.position = Vector2(0, -132.2)
        $Actions.position = Vector2(0, 0)
    else:
        $Camera2D.global_position = thing.global_position
        $Actions.global_position = thing.global_position