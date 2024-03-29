extends Node

var loaded_save = null

var house = []
var memory = []
var rng_seed = 0
var npcs = []
var scene_store = ''

var dateset = {
    'year': 8100,
    'month': 10,
    'day': 10,
    'daytime': ['Morning', 'Afternoon', 'Late Afternoon', 'Night'],
    'hours': 5,
    'energy': 10,
   }
var date = {
    'year': 0,
    'month': 0,
    'day': 0,
    'daytime': 0,
    'hours': 0,
    'energy': 0,
   }

const TRANSITION = preload('res://Scenes/UI/Transition.tscn')
const SPEECH = preload("res://Scenes/UI/TextBubble.tscn")
const NPC = preload('res://Scenes/NPC.tscn')

enum LIKES {
    games,
    art,
    nature,
    food,
    music,
    electronics,
    spaceships,
    space,
}

enum BEHAVE {
    stop,
    wander,
    work,
    house,
    hobby,
}

func _ready():
    pause_mode = Node.PAUSE_MODE_PROCESS
    randomize()
    rng_seed = floor(rand_range(0, 100000))
    seed(rng_seed)
    
    var file = File.new()
    file.open('res://Text/NameParts.tres', File.READ)
    var name_list = file.get_as_text().split('\n', false)
    file.close()
    
    var likes_left = LIKES.values()
    for _i in range(int(rand_range(3, 6))):
        var gen_npc = {}
        
        var npc_name = ''
        for _i in range(int(rand_range(2, 4))):
            npc_name += rand_item(name_list)
        
        var npc_likes = int(likes_left[rand_range(0, likes_left.size() - 1)])
        likes_left.erase(npc_likes)
        
        var scenes = [
                'res://Scenes/Places/House.tscn',
                'res://Scenes/Places/Town.tscn',
                ]
        var npc_scene = rand_item(scenes)
        
        gen_npc['name'] = npc_name
        gen_npc['likes'] = npc_likes
        gen_npc['scene'] = npc_scene
        npcs.append(gen_npc)

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
            if node.is_in_group('NPC'):
                continue
            
            # Encoding?
            var gps = node.global_position
            var pos = str(gps.x) + ' ' + str(gps.y)
            gps = node.scale
            var scl = str(gps.x) + ' ' + str(gps.y)
            
            house.append({'file':node.filename,
                    'pos': pos,
                    'sprite': node.get_node('Sprite').texture.resource_path,
                    'scale': scl,
                    })
    var file = File.new()
    var dir = Directory.new()
    var content = {
            'house': house,
            'scene': get_tree().current_scene.filename,
            'memory': memory,
            'seed': rng_seed,
            'npcs': npcs,
            'dateset': dateset,
            'date': date,
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
    rng_seed = loading['seed']
    npcs = loading['npcs']
    seed(rng_seed)
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

func load_npcs():
    var i = 0
    for npc in npcs:
        if npc['scene'] == get_tree().current_scene.filename:
            var spawnpoints = get_tree().get_nodes_in_group('Spawn')
            var spawn = rand_item(spawnpoints)
            var npc_inst = NPC.instance()
            get_tree().current_scene.add_child(npc_inst)
            npc_inst.global_position = spawn.global_position
            npc_inst.global_position.y += i * 100
            npc_inst.load_npc_inst(npc)
            i += 1

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
        yield(cutscene(what.info), 'completed')
    else:
        yield(cutscene(["I don't know what this is."]), 'completed')
    player.get_node('CollisionShape2D').disabled = false
    player.can_walk = true
    return

func cutscene(var what = ['Error', 'Dialogue data loaded incorrectly.']):
    var speech = SPEECH.instance()
    get_tree().current_scene.add_child(speech)
    for item in what:
        speech.think(item)
        yield(speech, "ended_line")
    speech.queue_free()

func Greet(var what):
    var myname = what.filename.replace('res://Scenes/Placeables/', '')
    myname = myname.replace('.tscn', '')
    if 'can_walk' in what:
        what.can_walk = false
    if 'id' in what:
        myname = what.id.name.capitalize()
        
    var player = get_tree().current_scene.get_node('Player')
    player.disconnect('got_there', Global, 'Greet')
    player.get_node('Scrat').scale.x = what.get_node('Scrat').scale.x * -1
    var list = []
    
    var rand = ['You say hi to ',
            'You say hello to ',
            'You greet ',
            ]
    
    list.append(rand_item(rand) + myname + '.')
    list.append('...')
    
    rand = [' says hi back!',
            ' says hello back!',
            ' greets you back!',
            ' says hi too!',
            ' says hello too!',
            ' greets you too!',
            ]
    
    list.append(myname + rand_item(rand))
    
    yield(cutscene(list), 'completed')
    focus_camera(player)
    player.get_node('CollisionShape2D').disabled = false
    if 'can_walk' in what:
        what.can_walk = true
    yield(get_tree().create_timer(0.05), 'timeout')
    player.can_walk = true

func rand_item(list):
    return list[randi() % len(list)]
