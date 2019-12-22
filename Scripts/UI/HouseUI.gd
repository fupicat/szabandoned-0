extends CanvasLayer

func _ready():
    $UI/Items.hide()

func _on_Mode_pressed():
    get_parent().switch_edit_mode()
    if get_parent().edit_mode:
        $UI/Mode.text = "Accept"
        $UI/Items.show()
    else:
        $UI/Mode.text = "Edit Mode"
        $UI/Items.hide()

func _on_SmallRoom_pressed():
    get_parent().add_placeable(load("res://Scenes/Placeables/SmallRoom.tscn"))