extends Control

const STAGE_BOX_SCENE = preload("res://stage_box.tscn")

@onready var stage_container = $Background/CenterContainer_Global/VBoxContainer_Outer/StageContainer
@onready var back_button = $Background/CenterContainer_Global/VBoxContainer_Outer/BackButton

# DATA HANYA UNTUK SATU STAGE. DITETAPKAN Bintang = 0.
var single_stage_data = [
    {"id": 1, "name": "Stage 1", "unlocked": true, "stars": 0, "path": "res://scenes/stage_1.tscn"}
]

func _ready():
    back_button.pressed.connect(_on_back_button_pressed)
    initialize_stages(single_stage_data)
    
    # Hubungkan sinyal StageBox1_Preview untuk suara (jika node itu ada)
    # Note: Karena StageBox di-instance, kita akan menghubungkannya di _populate_stage.
    # Namun, kita hubungkan Back Button di sini.
    back_button.pressed.connect(_on_button_clicked) 


func initialize_stages(data):
    # Membersihkan node yang sudah ada (menghilangkan duplikasi visual bintang 9)
    for child in stage_container.get_children():
        child.queue_free()
        
    if data.size() > 0:
        _populate_stage(data[0])

func _populate_stage(data):
    if not is_instance_valid(stage_container):
        print("ERROR: StageContainer tidak valid.")
        return 
        
    var stage_box = STAGE_BOX_SCENE.instantiate()
    
    stage_container.add_child(stage_box) 

    # Hubungkan sinyal Stage Box yang baru di-instance untuk suara klik
    stage_box.pressed.connect(_on_button_clicked)

    # Mengirim data {"stars": 0} ke Stage Box
    if stage_box.has_method("setup_stage"):
        stage_box.setup_stage(data)

# Fungsi baru untuk memanggil SFX saat tombol apa pun di scene ini ditekan
func _on_button_clicked():
    var main_menu = get_parent()
    if is_instance_valid(main_menu) and main_menu.has_method("play_click_sfx"):
        main_menu.play_click_sfx()

func _on_back_button_pressed():
    var main_menu = get_parent()
    
    # Panggil suara klik (sudah dilakukan oleh _on_button_clicked yang terhubung ke back_button)

    if is_instance_valid(main_menu) and main_menu.has_node("MenuContainer"):
        main_menu.get_node("MenuContainer").visible = true
        
    queue_free()
