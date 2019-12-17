extends KinematicBody2D

var move = Vector2(0, 0)
const SPEED = 400
const SLIP = 0.20

func _physics_process(delta):
    z_index = position.y
    var ydir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
    move.y = lerp(move.y, SPEED * ydir, SLIP)
    
    var xdir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
    move.x = lerp(move.x, SPEED * xdir, SLIP)
    
    move_and_slide(move)