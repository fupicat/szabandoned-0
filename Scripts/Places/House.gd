extends Node2D

var old_xy = Vector2(0, 0)
var old_col = null

func _ready():
    $Player/Camera2D.limit_left = -3500
    $Player/Camera2D.limit_right = 3500
    $Player/Camera2D.limit_bottom = 4720

func _input(event):
    if event.is_action_pressed("1"):
        old_xy = $Player.global_position
        $Player.hide()
        old_col = $Player/CollisionShape2D.shape
        var obj = load("res://Scenes/Placeables/SmallRoom.tscn").instance()
        add_child(obj)
        obj.get_node("Col").disabled = true
        $Player/CollisionShape2D.shape = obj.get_node("Col").shape
        obj.move = true
    if event.is_action_pressed("action"):
        $Player.global_position = old_xy
        $Player/CollisionShape2D.shape = old_col
        $Player.show()
        $Player/CollisionShape2D.disabled = false