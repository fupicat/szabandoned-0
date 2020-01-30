extends Node2D

func _ready():
    $Player/Camera2D.limit_left = 0
    $Player/Camera2D.limit_right = 7000
    $Player/Camera2D.limit_bottom = 3780

func _on_ToHouse_body_entered(body):
    if body == $Player:
        $Player.can_walk = false
        Global.transition_scene('res://Scenes/Places/House.tscn')
