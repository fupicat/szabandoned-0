extends CanvasLayer

func _on_Continue_pressed():
    Global.pause()

func _on_Save_pressed():
    Global.pause()
    Global.save_game()

func _on_Load_pressed():
    Global.pause()
    Global.load_game()

func _on_Quit_pressed():
    Global.pause()
    Global.save_game()
    get_tree().quit()
