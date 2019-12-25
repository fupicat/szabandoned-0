extends Area2D

var move = false

func _ready():
    update_z()

func _physics_process(delta):
    if move:
        global_position = get_parent().get_node("Player").global_position
        update_z()

func update_z():
    for node in get_overlapping_areas():
        if get_tree().get_nodes_in_group("Wall").has(node):
            z_index = node.z_index

func _input(event):
    if event.is_action_pressed("action"):
        if move:
            place()

func place():
    var wall = null
    for node in get_overlapping_areas():
        if get_tree().get_nodes_in_group("Wall").has(node):
            wall = node
    if wall != null:
        move = false
        var selfdup = $".".duplicate().instance()
        wall.add_child(selfdup)
        selfdup.global_position = global_position
        selfdup.z_index = 0
        get_parent().get_node("Player").global_position = Vector2(3149.61, 1287.24)
        queue_free()