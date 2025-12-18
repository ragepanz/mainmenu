extends CanvasLayer # Atau Control, tergantung node kamu apa

func _ready():
    visible = false # Sembunyi saat game mulai

func toggle_pause():
    # Fungsi ini yang dipanggil oleh tombol tadi
    visible = !visible
    get_tree().paused = visible # Stop/Jalan waktu game

func _on_btn_resume_pressed():
    toggle_pause() # Lanjut main

func _on_btn_quit_pressed():
    get_tree().paused = false # Penting: Unpause dulu sebelum pindah scene
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn") # Sesuaikan path menu utama
