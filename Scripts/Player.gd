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
    
    var up = int(Input.is_action_pressed("up"))
    var down = int(Input.is_action_pressed("down"))
    var left = int(Input.is_action_pressed("left"))
    var right = int(Input.is_action_pressed("right"))
    
    var run = RUNADD * int(Input.is_action_pressed("run"))
    var ydir = down - up
    move.y = lerp(move.y, (SPEED + run) * ydir, SLIP) * int(can_walk)
    
    var xdir = right - left
    move.x = lerp(move.x, (SPEED + run) * xdir, SLIP) * int(can_walk)
    
    if can_walk:
        if xdir == 1:
            $Scrat.scale.x = 1
        elif xdir == -1:
            $Scrat.scale.x = -1
    
    if target != null:
        $Scrat.scale.x = 1
        if target.x < global_position.x:
            $Scrat.scale.x = -1
        move = (target - position).normalized() * (SPEED + RUNADD)
        if move.x > 0:
            $Scrat.scale.x = 1
        else:
            $Scrat.scale.x = -1
        if (target - position).length() < 20:
            move = Vector2(0, 0)
            global_position = target
            target = null
            emit_signal('got_there')
    
    if can_walk and can_animate:
        $CollisionShape2D.disabled = false
    
    move = move_and_slide(move)
    
    anim_walk()

func _input(event):
    var is_house = get_tree().current_scene.filename.ends_with('House.tscn')
    
    if event.is_action_pressed("action") and !$Actions.phantom_select:
        if is_house and get_parent().edit_mode or !can_walk:
            return
        interact_with()
        
    if event.is_action_pressed('run') and !can_animate and !can_walk:
        cancel_action()
        
    if event.is_action_pressed("click"):
        if is_house and get_parent().edit_mode:
            target_mouse()
            return
        interact_with(true)
    
    var up = event.is_action_pressed("up")
    var down = event.is_action_pressed("down")
    var left = event.is_action_pressed("left")
    var right = event.is_action_pressed("right")
    
    if up or down or left or right:
        if target != null and !$Actions.visible:
            target = null
            can_walk = true

func interact_with(var mouse = false):
    var inters = get_tree().get_nodes_in_group("Interactable")
    
    if len(inters) > 0 and !$Actions.visible:
        var onmes = []
        var upper = null
        
        for node in inters: # Get all nodes the player is touching.
            if (!mouse and node.on_me) or (mouse and node.hover_me):
                onmes.append(node)
        
        var lookings = []
        if !mouse:
            for node in onmes: # Get all nodes the player is looking at.
            
                var looks_right = $Scrat.scale.x > 0
                var is_right = node.global_position.x > global_position.x
            
                if (looks_right and is_right) or (!looks_right and !is_right):
                    lookings.append(node)
        
        var on_look = onmes if mouse else lookings
        if len(on_look) > 0:
            upper = on_look[0]
            
            for node in on_look:
                if node.z_index > upper.z_index:
                    upper = node
                    
            if len(upper.interact) > 0 and can_animate:
                set_camera(upper)
                $Actions.menu(upper, upper.interact)
            elif mouse:
                target_mouse()
        elif mouse:
            target_mouse()
    elif mouse:
        target_mouse()

func target_mouse():
    if ('on_UI' in get_parent()) and get_parent().on_UI:
        return
    if can_walk:
        target = get_global_mouse_position()
        for node in get_tree().get_nodes_in_group('Exit'):
            if node.on_me:
                target = node.global_position
    elif !can_animate:
        cancel_action()

func walk_to(var obj):
    if obj.has_node('IntPos'):
        if 'can_walk' in obj:
            obj.can_walk = false
        can_walk = false
        $CollisionShape2D.disabled = true
        target = obj.get_node('IntPos').global_position
    else:
        can_walk = false
        $CollisionShape2D.disabled = true
        target = global_position

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
    for con in get_signal_connection_list('got_there'):
        disconnect('got_there', con['target'], con['method'])

func set_camera(var thing = null):
    if thing == null:
        $Camera2D.position = Vector2(0, -132.2)
        $Actions.position = Vector2(0, 0)
    else:
        $Camera2D.global_position = thing.global_position
        $Actions.global_position = thing.global_position
