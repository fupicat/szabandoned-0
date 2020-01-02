extends KinematicBody2D

var move = Vector2(0, 0)
const SPEED = 400
const RUNADD = 400
const SLIP = 0.20

var can_walk = true

func _physics_process(delta):
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
    
    move_and_slide(move, Vector2(0, -1))

func _input(event):
    if event.is_action_pressed("action") and !get_parent().edit_mode and !$Actions.select:
        var inters = get_tree().get_nodes_in_group("Interactable")
        if len(inters) > 0:
            var onmes = []
            var upper = null
            for node in inters: # Get all interactable nodes and detect which ones the player is touching.
                if node.on_me:
                    onmes.append(node)
            var lookings = []
            print('onmes = ' + str(onmes))
            for node in onmes: # Get all nodes the player is looking at.
                if ($Scrat.scale.x > 0 and node.global_position.x > global_position.x) or ($Scrat.scale.x < 0 and node.global_position.x < global_position.x):
                    lookings.append(node)
            if len(lookings) > 0:
                upper = lookings[0]
                print('lookings = ' + str(lookings))
                for node in lookings:
                    if node.z_index > upper.z_index:
                        upper = node
                print('upper = ' + str(upper))
                if len(upper.interact) > 0:
                    $Actions.menu(upper, upper.interact)