extends Area2D

var on_me = false

func _on_body_entered(body):
    var player = get_parent().get_parent().get_node("Player")
    if body == player and player.z_index < get_parent().z_index:
        get_parent().modulate = Color(1, 1, 1, 0.54902)

func _on_body_exited(body):
    if body == get_parent().get_parent().get_node("Player"):
        get_parent().modulate = Color(1, 1, 1, 1)