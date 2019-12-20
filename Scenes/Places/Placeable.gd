extends StaticBody2D

var move = false

func _ready():
    update_z()

func _physics_process(delta):
    if move:
        global_position = Vector2(clamp(get_parent().get_node("Player").global_position.x, -3500, 3500), clamp(get_parent().get_node("Player").global_position.y, 1000, 4700))
        update_z()

func update_z():
    z_index = global_position.y / 50

func _input(event):
    if event.is_action_pressed("action"):
        move = false