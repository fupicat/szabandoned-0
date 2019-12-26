extends Area2D

var move = false
var areas = []

func _ready():
    update_z()

func _physics_process(delta):
    areas = get_overlapping_areas()
    print(areas)
    if move:
        global_position = get_parent().get_node("Player").global_position
        update_z()

func update_z():
    for node in areas:
        if get_tree().get_nodes_in_group("Wall").has(node):
            z_index = node.z_index + 1

func _input(event):
    if event.is_action_pressed("action"):
        if move:
            place()

func place():
    var wall = false
    print(areas)
    for node in areas:
        if get_tree().get_nodes_in_group("Wall").has(node):
            wall = true
    if wall:
        move = false
    print(wall)
    return wall