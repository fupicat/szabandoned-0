extends KinematicBody2D

var move = Vector2(0, 0)
var speed = 500
const SLIP = 0.20

var interact = ['Greet']
var requires = {}
var id = {
        name = 'Default Name',
        memory = [],
        likes = 0,
        formal = 0,
        routine = [],
        }

var on_me = false
var hover_me = false

var target = null
var can_walk = true

var behavior = 1

var player = null

signal got_there

func _ready():
    $IntPos.position = Vector2(240, 0)
    if $Scrat.scale.x == -1:
        $IntPos.position = Vector2(-240, 0)
    if len(id['routine']) == 0:
        # Generate routine for the first time
        var temp_behave = Global.BEHAVE.keys()
        for _i in range(len(Global.dateset['daytime'])):
            if len(temp_behave) == 0:
                temp_behave = Global.BEHAVE.keys()
            var val = Global.rand_item(temp_behave)
            id['routine'].append(val)
            temp_behave.erase(val)
        print(id.routine)
    
    player = get_tree().current_scene.get_node('Player')
    
    update_z()
    seed(Global.rng_seed)
    
    if behavior == Global.BEHAVE.wander:
        $Wander.start(rand_range(0, 3))

func _physics_process(_delta):
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
    
    if behavior == Global.BEHAVE.stop:
        target = global_position
        $Scrat.scale.x = 1
        if player.global_position.x < global_position.x:
            $Scrat.scale.x = -1
    
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
    if behavior == Global.BEHAVE.wander:
        
        var rand_x = global_position.x + rand_range(-(speed * 3), speed * 3)
        var rand_y = global_position.y + rand_range(-(speed * 3), speed * 3)
        
        target = Vector2(rand_x, rand_y)
        $Wander.start(rand_range(0, 3))

func _on_Interact_body_entered(body):
    if body == player:
        on_me = true
        if behavior == Global.BEHAVE.wander:
            behavior = Global.BEHAVE.stop

func _on_Interact_body_exited(body):
    if body == player:
        on_me = false
        if hover_me or player.get_node('Actions').visible:
            return
        if behavior == Global.BEHAVE.stop:
            behavior = Global.BEHAVE.wander
            $Wander.start(rand_range(0, 3))

func _on_Interact_mouse_entered():
    hover_me = true
    if behavior == Global.BEHAVE.wander:
        behavior = Global.BEHAVE.stop

func _on_Interact_mouse_exited():
    hover_me = false
    if on_me or player.get_node('Actions').visible:
        return
    if behavior == Global.BEHAVE.stop:
        behavior = Global.BEHAVE.wander
        $Wander.start(rand_range(0, 3))

func update_z():
    #warning-ignore:NARROWING_CONVERSION
    z_index = global_position.y / 10
    if player.global_position.y > global_position.y:
        z_index -= 1
    else:
        z_index += 1

func load_npc_inst(var npc : Dictionary):
    assert(npc != null)
    for thing in npc.keys():
        if id.keys().has(thing):
            id[thing] = npc[thing]
