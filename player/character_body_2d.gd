extends CharacterBody2D

# ==========================================
# 🔌 NODE REFERENCES
# ==========================================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hand_item: Sprite2D = $HandItem 
@export_enum("basecamp", "gempa") var map_type: String = "basecamp"

# ==========================================
# ⚙️ PARAMETER GAME
# ==========================================
var speed = 200 
var last_direction = "South"
var last_item_in_hand = ""

# --- BATAS MAP ---
var screen_width  = 1280
var screen_height = 720
var map_width     = 5800
var map_height    = 1050

# Batas gerak
var min_x = 0; var min_y = 0; var max_x = 0; var max_y = 0

# --- PERSPEKTIF ---
var base_scale := Vector2.ONE

# ==========================================
# 🚀 MAIN LOOP
# ==========================================
func _ready():
    # Hitung batas jalan
    max_x = map_width - screen_width
    max_y = map_height - screen_height
    
    # Set animasi awal
    if sprite.sprite_frames.has_animation("Idle_South"):
        sprite.animation = "Idle_South"
        sprite.play()
    
    # Konfigurasi per Map
    if map_type == "basecamp":
        base_scale = Vector2(4, 4)
        speed = 200 
    elif map_type == "gempa":
        base_scale = Vector2(1.6, 1.6)
        speed = 120 
    
    # Koneksi Hotbar
    var hotbar = get_tree().get_first_node_in_group("Hotbar")
    if hotbar and hotbar.has_node("Bar"):
        if not hotbar.get_node("Bar").is_connected("item_changed", _on_hotbar_item_changed):
            hotbar.get_node("Bar").connect("item_changed", _on_hotbar_item_changed)

    _update_hand_item()

func _process(_delta):
    # Toggle Backpack (Tab)
    if Input.is_action_just_pressed("ui_tab") or Input.is_key_pressed(KEY_TAB): 
        if get_tree().current_scene.has_node("BackpackUI"):
            get_tree().current_scene.get_node("BackpackUI").toggle_ui()
    
    _apply_perspective_scale()
    _update_hand_item()

func _physics_process(delta):
    _move_player(delta)
    _limit_player_position()

# ==========================================
# 🏃 GERAKAN PLAYER (VERSI ARROW KEYS)
# ==========================================
func _move_player(_delta):
    # 🔥 PAKAI INPUT BAWAAN (ARROW KEYS)
    # ui_left, ui_right, ui_up, ui_down itu otomatis tombol PANAH
    var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    var target_animation = ""
    
    # Faktor pelan saat jalan vertikal di map gempa
    var vertical_speed_factor = 1.0
    if map_type == "gempa":
        vertical_speed_factor = 0.5

    if input_vector != Vector2.ZERO:
        # Update Arah Terakhir
        if input_vector.x > 0: last_direction = "East"
        elif input_vector.x < 0: last_direction = "West"
        elif input_vector.y > 0: last_direction = "South"
        elif input_vector.y < 0: last_direction = "North"
        
        # Set Animasi Jalan
        if input_vector.y < 0:
            target_animation = "Run_North"
            sprite.flip_h = false
        elif input_vector.y > 0:
            target_animation = "Run_South"
            sprite.flip_h = false
        elif input_vector.x != 0:
            # Kiri/Kanan pakai Run_East + Flip
            target_animation = "Run_East" 
            if input_vector.x < 0:
                sprite.flip_h = true # Hadap Kiri
            else:
                sprite.flip_h = false # Hadap Kanan
        
        # Hitung Velocity
        var velocity_vector = input_vector
        if velocity_vector.y != 0:
            velocity_vector.y *= vertical_speed_factor
            
        velocity = velocity_vector * speed
    else:
        # IDLE (Diam)
        velocity = Vector2.ZERO
        target_animation = "Idle_%s" % last_direction
        
        # Handle Flip saat Idle
        if last_direction == "West":
            target_animation = "Idle_East" 
            sprite.flip_h = true
        elif last_direction == "East":
            target_animation = "Idle_East"
            sprite.flip_h = false

    # Play Animasi
    if sprite.animation != target_animation:
        if sprite.sprite_frames.has_animation(target_animation):
            sprite.animation = target_animation
            sprite.play()
        # Fallback animasi dihapus biar gak error
            
    move_and_slide()

# ==========================================
# 📐 PERSPEKTIF & BATAS
# ==========================================
func _apply_perspective_scale():
    var min_s = 0.0; var max_s = 0.0; var top_l = 0.0; var bot_l = 0.0
    
    if map_type != "gempa":
        min_s = 0.75; max_s = 1.15; top_l = 30.0; bot_l = 180.0
    else:
        min_s = 0.65; max_s = 1.2; top_l = 130.0; bot_l = 280.0

    var t = clamp((global_position.y - top_l) / (bot_l - top_l), 0.0, 1.0)
    scale = base_scale * lerp(min_s, max_s, t)

    if has_node("Shadow"):
        $Shadow.scale = Vector2(scale.x * 0.8, scale.y * 0.5)

func _limit_player_position():
    global_position.x = clamp(global_position.x, min_x, max_x)
    global_position.y = clamp(global_position.y, min_y, max_y)

# ==========================================
# 🎒 ITEM HANDLING
# ==========================================
func _update_hand_item():
    if hand_item == null: return
    if not has_node("/root/Global"): return 

    var current = Global.current_item
    if current == null or current == "":
        if hand_item.texture != null:
            hand_item.texture = null
            last_item_in_hand = ""
        return

    if current == last_item_in_hand: return

    last_item_in_hand = current
    var data = Global.get_item_data(current)

    if data != null:
        hand_item.texture = data.icon
        hand_item.scale = Vector2(0.05, 0.05)
        hand_item.centered = true
    else:
        hand_item.texture = null

func _on_hotbar_item_changed(item_name):
    if hand_item == null: return
    if item_name == last_item_in_hand: return
    last_item_in_hand = item_name
    
    if not has_node("/root/Global"): return
    var data = Global.get_item_data(item_name)
    if data != null:
        hand_item.texture = data.icon
        hand_item.scale = Vector2(0.05, 0.05)
        hand_item.centered = true
    else:
        hand_item.texture = null

func get_current_item():
    if has_node("/root/Global"):
        return Global.current_item
    return ""
