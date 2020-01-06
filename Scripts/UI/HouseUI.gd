extends CanvasLayer

func _ready():
    $UI/Items.hide()

func _on_Mode_pressed():
    get_parent().switch_edit_mode()

func _on_SmallRoom_pressed():
    get_parent().add_placeable(load("res://Scenes/Placeables/SmallRoom.tscn"))

func _on_Move_pressed():
    get_parent().move_mode = true
    get_parent().switch_edit_mode()

func _on_Sofa_pressed():
    get_parent().add_placeable(load("res://Scenes/Placeables/Sofa.tscn"))

func _on_Delete_pressed():
    get_parent().delete_mode = true
    get_parent().switch_edit_mode()