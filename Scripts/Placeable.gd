extends StaticBody2D

var move = false
#warning-ignore:UNUSED_CLASS_VARIABLE
export var interact = []
var on_me = false

func _ready():
    update_z()

func _physics_process(_delta):
    if move:
        global_position = Vector2(clamp(get_parent().get_node("Player").global_position.x, -3500, 3500), clamp(get_parent().get_node("Player").global_position.y, 1000, 4700))
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

func place():
    if get_parent().get_node('Grama/Path').get_overlapping_bodies().has(get_parent().get_node('Player')):
        return false
    move = false
    $Col.disabled = false
    return true