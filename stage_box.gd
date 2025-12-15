extends Button

const FULL_STAR = preload("res://asset/stage/star3.png") 
const EMPTY_STAR = preload("res://asset/stage/starkosong.png") 

@onready var star_container = $VBoxContainer/StarContainer
@onready var level_image = $VBoxContainer/LevelImage
@onready var level_name = $VBoxContainer/LevelName
@onready var lock_overlay = $LockOverlay

func setup_stage(data):
    level_name.text = data.name
    level_image.texture = data.image
    
    # Ambil 3 node bintang pertama aja (Star1, Star2, Star3)
    # Ini buat mastiin kalo di editor lu ada 9 bintang, yang dipake cuma 3
    var stars_nodes = star_container.get_children()
    
    # Sembunyikan semua bintang dulu buat reset
    for s in stars_nodes:
        s.visible = false
    
    # Update maksimal 3 bintang
    var collected_stars = data.get("stars", 0)
    for i in range(3):
        if i < stars_nodes.size():
            var star_node = stars_nodes[i]
            star_node.visible = true # Munculin cuma 3 biji
            if i < collected_stars:
                star_node.texture = FULL_STAR
            else:
                star_node.texture = EMPTY_STAR

    # Logika Kunci
    if data.unlocked:
        lock_overlay.visible = false
        disabled = false
        star_container.modulate.a = 1.0 # Bintang terang
    else:
        lock_overlay.visible = true
        disabled = true
        star_container.modulate.a = 0.5 # Bintang redup tapi tetep keliatan 3 biji kosong

    if data.unlocked and not pressed.is_connected(_on_pressed.bind(data.path)):
        pressed.connect(_on_pressed.bind(data.path))

func _on_pressed(path):
    get_tree().change_scene_to_file(path)
