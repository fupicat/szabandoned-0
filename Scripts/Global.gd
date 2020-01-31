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
            
            # Encoding?
            var gps = node.global_position
            var pos = str(gps.x) + ' ' + str(gps.y)
            gps = node.scale
            var scl = str(gps.x) + ' ' + str(gps.y)
            
            house.append({'file':node.filename,
                    'pos':pos,
                    'sprite':node.get_node('Sprite').texture.resource_path,
                    'scale':scl,
                    })
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
    var tree = get_tree()
    tree.paused = !get_tree().paused
    tree.current_scene.get_node('Pause/Pause').visible = get_tree().paused

func transition_scene(var scene, var transition = ''):
    scene_store = scene
    var trans = TRANSITION.instance()
    get_tree().current_scene.add_child(trans)
    
    var anim = trans.get_node("Anim")
    anim.connect("animation_finished", Global, 'transition_end')
    anim.play(transition + 'In')

func transition_end(_anim_name):
    var _err = get_tree().change_scene(scene_store)

# Actions

func walk2do(var upper, var action):
    var player = get_tree().current_scene.get_node('Player')
    player.walk_to(upper)
    var connect_to = null
    if has_method(action):
        connect_to = Global
    elif get_tree().current_scene.has_method(action):
        connect_to = get_tree().current_scene
    assert(connect_to != null)
    
    var _err = player.connect('got_there', connect_to, action, [upper])

func Sit(var onwhat):
    var player = get_tree().current_scene.get_node('Player')
    
    player.disconnect('got_there', Global, 'Sit')
    player.can_walk = false
    var path = onwhat.get_node('Sprite').texture.resource_path
    player.z_index = onwhat.z_index - 1
    player.global_position = onwhat.get_node('Sit').global_position
    if path.ends_with('Side.png'):
        if onwhat.scale.x == 1:
            player.animation('SitRight')
        else:
            player.animation('SitLeft')
    elif path.ends_with('Front.png'):
        player.z_index = onwhat.z_index + 1
        player.animation('SitFront')
    elif path.ends_with('Back.png'):
        player.animation('SitFront')
