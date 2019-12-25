extends KinematicBody2D

var move = Vector2(0, 0)
const SPEED = 400
const RUNADD = 400
const SLIP = 0.20

func _physics_process(delta):
    z_index = global_position.y / 10
    var run = RUNADD * int(Input.is_action_pressed("run"))
    var ydir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
    move.y = lerp(move.y, (SPEED + run) * ydir, SLIP)
    
    var xdir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
    move.x = lerp(move.x, (SPEED + run) * xdir, SLIP)
    
    move_and_slide(move, Vector2(0, -1))

func _input(event):
    if event.is_action_pressed("action"):
        var inters = get_tree().get_nodes_in_group("Interactive")
        if len(inters) > 0:
            var onmes = []
            var upper = null
            for node in inters: # Get all interactable nodes and detect which ones the player is touching.
                if node.on_me:
                    onmes.append(node)
            if len(onmes) > 0:
                upper = onmes[0]
                if len(onmes) > 1:
                    for node in onmes: # Get all nodes the player is touching and gets the one with the highest z_index.
                        if node.z_index > upper.z_index:
                            upper = node
                print(upper)
        print("Done")