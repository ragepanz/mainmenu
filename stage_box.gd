extends Button

# Asumsi path ini benar
const FULL_STAR = preload("res://asset/stage/star.png")
const EMPTY_STAR = preload("res://asset/stage/starkosong.png") 

# Deklarasikan variabel tanpa inisialisasi @onready
var stars = []
@onready var level_name = $VBoxContainer/LevelName
@onready var lock_overlay = $LockOverlay


#func _ready():
    # KOREKSI UTAMA: Dapatkan referensi node secara manual di _ready().
    # Fungsi get_node_internal() lebih stabil untuk node anak langsung.
    #stars.append(get_node_internal("VBoxContainer/StarContainer/Star1"))
    #stars.append(get_node_internal("VBoxContainer/StarContainer/Star2"))
    #stars.append(get_node_internal("VBoxContainer/StarContainer/Star3"))

func setup_stage(data):
    # Cek untuk memastikan array bintang sudah terisi dan tidak ada null
    if stars.is_empty() or stars.has(null):
        # Jika masih gagal (salah satu bintang null), hentikan fungsi.
        print("ERROR: Node bintang gagal dimuat. Cek stage_box.tscn.")
        return

    # Setel Nama Stage
    level_name.text = data.name
    
    # Atur Status Terkunci
    if data.unlocked:
        lock_overlay.visible = false
        disabled = false
    else:
        lock_overlay.visible = true
        disabled = true
        
    # Atur Status Bintang (Logika 0 Bintang)
    var collected_stars = data.stars
    
    for i in range(stars.size()): 
        # Cek jika bintang sudah terisi dengan benar sebelum mencoba mengatur texture
        if stars[i]:
            if i < collected_stars:
                # Bintang penuh jika i < jumlah bintang yang dikumpulkan
                stars[i].texture = FULL_STAR
            else:
                # Bintang kosong jika i >= jumlah bintang yang dikumpulkan
                stars[i].texture = EMPTY_STAR 

    # Hubungkan sinyal (jika stage tidak terkunci)
    if data.unlocked:
        pressed.connect(_on_stage_box_pressed.bind(data.path))

func _on_stage_box_pressed(scene_path):
    print("Memuat Stage: " + scene_path)
    # Ganti scene di sini
