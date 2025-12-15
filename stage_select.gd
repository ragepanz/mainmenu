extends Control

const STAGE_BOX_SCENE = preload("res://stage_box.tscn")
@onready var stage_container = %StageContainer
@onready var back_button = $CenterContainer/VBoxContainer_Outer/BackButton

# DATA STAGE: Set stars ke 0 biar kosong pas awal
var stages_data = [
    {
        "id": 1,
        "name": "GEMPA BUMI",
        "stars": 0, # Default tanpa bintang
        "unlocked": true,
        "image": preload("res://asset/stage/stage1image.png"),
        "path": "res://scenes/stage_1.tscn"
    },
    {
        "id": 2,
        "name": "BANJIR",
        "stars": 0,
        "unlocked": false, # Dikunci
        "image": preload("res://asset/stage/stage2image.png"),
        "path": "res://scenes/stage_2.tscn"
    },
    {
        "id": 3,
        "name": "KEBAKARAN HUTAN",
        "stars": 0,
        "unlocked": false, # Dikunci
        "image": preload("res://asset/stage/stage3image.png"),
        "path": "res://scenes/stage_3.tscn"
    }
]

func _ready():
    initialize_menu()
    if back_button:
        back_button.pressed.connect(_on_back_button_pressed)

func initialize_menu():
    # Bersihkan container biar nggak numpuk pas di-load ulang
    for child in stage_container.get_children():
        child.queue_free()
    
    for data in stages_data:
        var box = STAGE_BOX_SCENE.instantiate()
        stage_container.add_child(box)
        box.setup_stage(data)

func _on_back_button_pressed():
    # Langsung pindah ke Main Menu
    get_tree().change_scene_to_file("res://main_menu.tscn")
