extends Node

var house = []

const TRANSITION = preload('res://Scenes/UI/Transition.tscn')

var scene_store = ''

func _init():
    pause_mode = Node.PAUSE_MODE_PROCESS

func _ready():
    var file = File.new()
    if file.file_exists("user://saves/save1.json"):
        load_game()
    else:
        save_game()

func _input(event):
    if event.is_action_pressed('pause'):
        pause()
        
func save_game(var quit = false):
    if get_tree().current_scene.filename == 'res://Scenes/Places/House.tscn':
        house = []
        for node in get_tree().get_nodes_in_group('Interactable'):
            house.append({'file':node.filename, 'pos':node.global_position, 'sprite':node.get_node('Sprite').texture.resource_path, 'scale':node.scale})
    var file = File.new()
    var dir = Directory.new()
    var content = {'house':house, 'scene':get_tree().current_scene.filename}
    if !dir.dir_exists('user://saves'):
        dir.make_dir('user://saves')
    file.open("user://saves/save1.json", File.WRITE)
    file.store_string(to_json(content))
    file.close()
    print('Game saved to ' + OS.get_user_data_dir())
    if quit:
        get_tree().quit()

func load_game():
    var file = File.new()
    file.open("user://saves/save1.json", File.READ_WRITE)
    var loading = parse_json(file.get_as_text())
    file.close()
    house = loading['house']
    var _err = get_tree().change_scene(loading['scene'])

func pause():
    get_tree().paused = !get_tree().paused
    get_tree().current_scene.get_node('Pause/Pause').visible = get_tree().paused

func transition_scene(var scene, var transition = ''):
    scene_store = scene
    var trans = TRANSITION.instance()
    get_tree().current_scene.add_child(trans)
    trans.get_node("Anim").connect("animation_finished", Global, 'transition_end')
    trans.get_node('Anim').play(transition + 'In')

func transition_end(_anim_name):
    var _err = get_tree().change_scene(scene_store)