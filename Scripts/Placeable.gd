extends StaticBody2D

var move = false
#warning-ignore:UNUSED_CLASS_VARIABLE
export var interact : PoolStringArray = []
#warning-ignore:UNUSED_CLASS_VARIABLE
export var xtra_sprites : PoolStringArray = []
#warning-ignore:UNUSED_CLASS_VARIABLE
export var info : PoolStringArray = []
#warning-ignore:UNUSED_CLASS_VARIABLE
export var requires : Dictionary = {}
var on_me = false
var hover_me = false

func _ready():
    update_z()
    var inter = $Interactive
    inter.connect("body_entered", $".", '_on_Interactive_body_entered')
    inter.connect("body_exited", $".", '_on_Interactive_body_exited')
    inter.connect("mouse_entered", $".", '_on_Interactive_mouse_entered')
    inter.connect("mouse_exited", $".", '_on_Interactive_mouse_exited')

func _physics_process(_delta):
    if move:
        global_position = get_parent().get_node("Player").global_position
        update_z()

func update_z():
    #warning-ignore:NARROWING_CONVERSION
    z_index = global_position.y / 10

func _on_Interactive_body_entered(body):
    if body == get_parent().get_node("Player"):
        on_me = true

func _on_Interactive_body_exited(body):
    if body == get_parent().get_node("Player"):
        on_me = false

func _on_Interactive_mouse_entered():
    hover_me = true

func _on_Interactive_mouse_exited():
    hover_me = false

func place():
    var grama = get_parent().get_node('Grama/Path')
    if grama.get_overlapping_bodies().has(get_parent().get_node('Player')):
        return false
    move = false
    $Col.disabled = false
    return true
