extends Control

func _ready():
    
    reload()

func _on_New_pressed():
    Global.loaded_save = $M/V/New/LineEdit.text
    Global.transition_scene('res://Scenes/Places/House.tscn')

func _on_Load_pressed():
    if $M/V/Load/OptionButton.get_item_count() != 0:
        Global.loaded_save = $M/V/Load/OptionButton.text
        Global.load_game()

func _on_Erase_pressed():
    if $M/V/Erase/OptionButton.get_item_count() != 0:
        var dir = Directory.new()
        dir.remove('user://saves/' + $M/V/Erase/OptionButton.text + '.json')
        reload()

func reload():
    $M/V/Load/OptionButton.clear()
    $M/V/Erase/OptionButton.clear()
    
    var dir = Directory.new()
    if !dir.dir_exists('user://saves'):
        dir.make_dir('user://saves')
    
    dir.open('user://saves')
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if !dir.current_is_dir():
            var item = file_name.replace('.json', '')
            $M/V/Load/OptionButton.add_item(item)
            $M/V/Erase/OptionButton.add_item(item)
        file_name = dir.get_next()
