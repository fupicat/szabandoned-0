extends KinematicBody2D

var move = Vector2(0, 0)
var speed = 500
const SLIP = 0.20

var on_me = false

var target = null
var can_walk = true

export var behavior = 1

signal got_there

enum BEHAVE {
    stop,
    wander
}

func _ready():
    randomize()
    update_z()
    if behavior == BEHAVE.wander:
        $Wander.start(rand_range(0, 3))

func _physics_process(delta):
    update_z()
    
    if target != null and can_walk:
        can_walk = true
        $Scrat.scale.x = 1
        if target.x < global_position.x:
            $Scrat.scale.x = -1
        move = (target - position).normalized() * (speed)
        if (target - position).length() < 20:
            move = Vector2(0, 0)
            global_position = target
            target = null
            can_walk = true
            emit_signal('got_there')
    
    move = move_and_slide(move)
    anim_walk()

func anim_walk():
    if can_walk:
        if abs(move.x) < 30 and abs(move.y) < 30:
            $Scrat/Anim.play("Idle")
        else:
            $Scrat/Anim.play("Walk")

func animation(var name):
    can_walk = false
    $Scrat.scale.x = 1
    $Scrat/Anim.play(name)

func _on_Wander_timeout():
    if behavior == BEHAVE.wander:
        target = Vector2(global_position.x + rand_range(-(speed * 3), speed * 3), global_position.y + rand_range(-(speed * 3), speed * 3))
        $Wander.start(rand_range(0, 3))

func _on_Interact_body_entered(body):
    if body == get_parent().get_node('Player'):
        on_me = true
        if behavior == BEHAVE.wander:
            behavior = BEHAVE.stop
            can_walk = false

func _on_Interact_body_exited(body):
    if body == get_parent().get_node('Player'):
        on_me = false
        if behavior == BEHAVE.stop:
            behavior = BEHAVE.wander
            can_walk = true
            $Wander.start(rand_range(0, 3))

func update_z():
    #warning-ignore:NARROWING_CONVERSION
    z_index = global_position.y / 10
    if get_parent().get_node('Player').global_position.y > global_position.y:
        z_index -= 1
    else:
        z_index += 1