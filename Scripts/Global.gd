extends Node

var loaded_save = null

var house = []
var memory = []

const TRANSITION = preload('res://Scenes/UI/Transition.tscn')
const SPEECH = preload("res://Scenes/UI/TextBubble.tscn")

var scene_store = ''

func _init():
    pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
    if event.is_action_pressed('pause'):
        pause()
    if event.is_action_pressed("mode"):
        add_to_memory('sign path')
        
func save_game(var save = null):
    if save == null:
        save = Global.loaded_save
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
    var content = {'house':house,
            'scene':get_tree().current_scene.filename,
            'memory':memory,
            }
    if !dir.dir_exists('user://saves'):
        dir.make_dir('user://saves')
    file.open("user://saves/" + save + ".json", File.WRITE)
    file.store_string(to_json(content))
    file.close()
    print('Game saved to ' + OS.get_user_data_dir())

func load_game(var save = null):
    if save == null:
        save = Global.loaded_save
    var file = File.new()
    file.open("user://saves/" + save + ".json", File.READ_WRITE)
    var loading = parse_json(file.get_as_text())
    file.close()
    house = loading['house']
    memory = loading['memory']
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

func has_requirements(var requires = []):
    if len(requires) == 0:
        return true
    
    var i = len(requires)
    for item in requires:
        if memory.has(item):
            i -= 1
    if i == 0:
        return true
    
    return false

func add_to_memory(var what : String):
    var to_add = what.split(' ')
    for item in to_add:
        if memory.has(item):
            continue
        memory.append(item)

func focus_camera(var obj):
    var here = get_tree().current_scene
    if here.has_node('Player/Camera2D'):
        here.get_node('Player/Camera2D').global_position = obj.global_position

# Actions

func walk2do(var upper, var action, var requires = []):
    var player = get_tree().current_scene.get_node('Player')
    player.walk_to(upper)
    var connect_to = null
    if has_method(action):
        connect_to = Global
    elif get_tree().current_scene.has_method(action):
        connect_to = get_tree().current_scene
    assert(connect_to != null)
    
    var binds = [upper]
    if len(requires) != 0:
        binds.append(requires)
        print(binds)
    
    print(action, binds)
    
    var _err = player.connect('got_there', connect_to, action, binds)

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

func Info(var what, var requires = []):
    var player = get_tree().current_scene.get_node('Player')
    player.disconnect('got_there', Global, 'Info')
    if has_requirements(requires):
        yield(cutscene_think(what.info), 'completed')
    else:
        yield(cutscene_think(["I don't know what this is."]), 'completed')
    player.get_node('CollisionShape2D').disabled = false
    player.can_walk = true
    return

func cutscene_think(var what = ['Error', 'Dialogue data loaded incorrectly.']):
    var speech = SPEECH.instance()
    get_tree().current_scene.add_child(speech)
    for item in what:
        speech.think(item)
        yield(speech, "ended_line")
    speech.queue_free()

func Chat(var what):
    print('Here')
    if 'can_walk' in what:
        what.can_walk = false
    var player = get_tree().current_scene.get_node('Player')
    player.disconnect('got_there', Global, 'Chat')
    player.get_node('Scrat').scale.x = what.get_node('Scrat').scale.x * -1
    var list = [['NPC', 'Hi'],
            ['Player', 'Hi'],]
    yield(cutscene_speak(list), 'completed')
    player.get_node('CollisionShape2D').disabled = false
    player.can_walk = true
    if 'can_walk' in what:
        what.can_walk = true
    return

func cutscene_speak(var what = [['Error', 'Dialog data loaded incorrectly.']]):
    var speech = SPEECH.instance()
    var here = get_tree().current_scene
    here.add_child(speech)
    for item in what:
        var char_name = 'Error'
        var obj = null
        
        if item[0] == 'Player':
            char_name = 'You'
            obj = here.get_node('Player')
            
        elif 'id' in here.get_node(item[0]):
            char_name = here.get_node(item[0]).id.name
            obj = here.get_node(item[0])
            
        elif item[0] is String:
            char_name = item[0]
            
        speech.speak(item[1], char_name, obj)
        yield(speech, "ended_line")
    speech.queue_free()
