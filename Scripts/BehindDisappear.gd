extends Area2D

func _on_body_entered(body):
    var player = get_parent().get_parent().get_node("Player")
    if body == player and player.z_index < get_parent().z_index and !get_parent().get_parent().edit_mode:
        get_parent().modulate.a = 0.54902

func _on_body_exited(body):
    if body == get_parent().get_parent().get_node("Player") and !get_parent().get_parent().edit_mode:
        get_parent().modulate.a = 1