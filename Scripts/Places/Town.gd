extends Node2D

func _ready():
    $Player/Camera2D.limit_left = 0
    $Player/Camera2D.limit_right = 7000
    $Player/Camera2D.limit_bottom = 3780

func _on_ToHouse_body_entered(body):
    if body == $Player:
        var _err = get_tree().change_scene('res://Scenes/Places/House.tscn')