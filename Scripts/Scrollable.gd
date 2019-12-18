extends Node2D

var cam = null
var start = Vector2(0, 0)

func _ready():
    cam = $"../../Player/Camera2D"

func _physics_process(delta):
    position = -cam.get_camera_position()