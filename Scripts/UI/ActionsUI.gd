extends Node2D

var active = ''
var select = false
var phantom_select = false
var the_obj = null
var the_actions = []

var hover_l = false
var hover_r = false
var hover_u = false
var hover_d = false

func _ready():
    for node in $Menu.get_children():
        node.connect('mouse_exited', $".", '_on_mouse_none')

func menu(var object, var actions):
    the_obj = object
    the_actions = actions
    
    $Label.text = object.filename.replace('res://Scenes/Placeables/', '').replace('.tscn', '')
    
    get_parent().can_walk = false
    get_parent().target = null
    var i = 0
    var file = File.new()
    for node in $Menu.get_children():
        node.hide()
    for act in actions:
        var texture = load('res://Art/GUI/Use.png')
        if file.file_exists('res://Art/GUI/' + act + '.png'):
            texture = load('res://Art/GUI/' + act + '.png')
        $Menu.get_child(i).texture_normal = texture
        $Menu.get_child(i).show()
        i+=1
    $Anim.stop()
    active = ''
    select = true
    phantom_select = true
    $Anim.play("In")

func _process(_delta):
    if select == true:
        for node in $Menu.get_children():
            node.modulate = Color(1, 1, 1)
        var lr = ''
        var ud = ''
        if hover_l and !hover_r:
            lr = 'L'
        if hover_r and !hover_l:
            lr = 'R'
        if hover_u and !hover_d:
            ud = 'U'
        if hover_d and !hover_u:
            ud = 'D'
        active = lr + ud
        $Label.text = the_actions[get_node('Menu/' + active).get_position_in_parent()] if active != '' and len(the_actions) > get_node('Menu/' + active).get_position_in_parent() else the_obj.filename.replace('res://Scenes/Placeables/', '').replace('.tscn', '')
    else:
        active = ''
    if active != '':
        get_node('Menu/' + active).modulate = Color(0.215686, 0.219608, 1)

func _input(event):
    if event.is_action_pressed("run") and select:
        get_parent().can_walk = true
        hide_menu()
    if event.is_action_pressed("action") and select:
        if active != '' and get_node('Menu/' + active).visible:
            get_parent().get_parent().call('walk2do', the_obj, the_actions[get_node('Menu/' + active).get_position_in_parent()])
        hide_menu()
        if active == '':
            get_parent().can_walk = true
    if event.is_action_pressed("click") and visible:
        $Click.start()
    
    # Barf
    if event.is_action_pressed('left'):
        hover_l = true
    if event.is_action_released('left'):
        hover_l = false
    if event.is_action_pressed('right'):
        hover_r = true
    if event.is_action_released('right'):
        hover_r = false
    if event.is_action_pressed('left') and event.is_action_pressed('right'):
        hover_l = false
        hover_r = false
    if event.is_action_pressed('up'):
        hover_u = true
    if event.is_action_released('up'):
        hover_u = false
    if event.is_action_pressed('down'):
        hover_d = true
    if event.is_action_released('down'):
        hover_d = false
    if event.is_action_pressed('left') and event.is_action_pressed('right'):
        hover_u = false
        hover_d = false

func _on_Timer_timeout():
    phantom_select = false
    
func _on_Click_timeout():
    if visible:
        hide_menu()

func _on_L_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/L.get_position_in_parent()])
    hide_menu()

func _on_R_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/R.get_position_in_parent()])
    hide_menu()

func _on_U_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/U.get_position_in_parent()])
    hide_menu()

func _on_D_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/D.get_position_in_parent()])
    hide_menu()

func _on_LU_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/LU.get_position_in_parent()])
    select = false
    hide()
    $Timer.start()

func _on_RU_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/RU.get_position_in_parent()])
    hide_menu()

func _on_RD_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/RD.get_position_in_parent()])
    hide_menu()

func _on_LD_pressed():
    get_parent().get_parent().call('walk2do', the_obj, the_actions[$Menu/LD.get_position_in_parent()])
    hide_menu()

func hide_menu():
    get_parent().set_camera()
    select = false
    hide()
    $Timer.start()

func _on_L_mouse_entered():
    hover_l = true
    hover_r = false
    hover_u = false
    hover_d = false

func _on_R_mouse_entered():
    hover_l = false
    hover_r = true
    hover_u = false
    hover_d = false

func _on_U_mouse_entered():
    hover_l = false
    hover_r = false
    hover_u = true
    hover_d = false

func _on_D_mouse_entered():
    hover_l = false
    hover_r = false
    hover_u = false
    hover_d = true

func _on_LU_mouse_entered():
    hover_l = true
    hover_r = false
    hover_u = true
    hover_d = false

func _on_RU_mouse_entered():
    hover_l = false
    hover_r = true
    hover_u = true
    hover_d = false

func _on_RD_mouse_entered():
    hover_l = false
    hover_r = true
    hover_u = false
    hover_d = true

func _on_LD_mouse_entered():
    hover_l = true
    hover_r = false
    hover_u = false
    hover_d = true

func _on_mouse_none():
    hover_l = false
    hover_r = false
    hover_u = false
    hover_d = false
