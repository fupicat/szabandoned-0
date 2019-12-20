extends Node2D

var old_xy = Vector2(0, 0)

func _ready():
    $Player/Camera2D.limit_left = -3500
    $Player/Camera2D.limit_right = 3500
    $Player/Camera2D.limit_bottom = 4720

func _input(event):
    if event.is_action_pressed("1"):
        old_xy = $Player.global_position
        $Player.hide()
        $Player/CollisionShape2D.disabled = true
        var obj = load("res://Scenes/Placeables/SmallRoom.tscn").instance()
        add_child(obj)
        obj.move = true
    if event.is_action_pressed("action"):
        $Player.global_position = old_xy
        $Player.show()
        $Player/CollisionShape2D.disabled = false