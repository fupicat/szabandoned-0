extends CanvasLayer

var on_UI = false

func _ready():
    $UI/Items.hide()
    $UI/Select.hide()
    for node in $UI.get_children():
        if node is Button:
            node.connect('mouse_entered', $".", '_on_mouse_entered')
            node.connect('mouse_exited', $".", '_on_mouse_exited')
            node.connect('focus_entered', $".", '_on_mouse_entered')
            node.connect('focus_exited', $".", '_on_mouse_exited')
    for node in $UI/Items/H.get_children():
        node.connect('mouse_entered', $".", '_on_mouse_entered')
        node.connect('mouse_exited', $".", '_on_mouse_exited')
        node.connect('focus_entered', $".", '_on_mouse_entered')
        node.connect('focus_exited', $".", '_on_mouse_exited')

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

func _on_Sign_pressed():
    get_parent().add_placeable(load("res://Scenes/Placeables/Sign.tscn"))

func _on_mouse_entered():
    get_parent().on_UI = true
    print(get_parent().on_UI)

func _on_mouse_exited():
    get_parent().on_UI = false
    print(get_parent().on_UI)

func _on_Select_pressed():
    if get_parent().move_mode:
        get_parent().move_obj()
    elif get_parent().delete_mode:
        get_parent().delete_obj()
