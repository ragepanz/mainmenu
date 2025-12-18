extends CanvasLayer

# ===============================
# HUD LABELS
# ===============================
@onready var label_timer  = $HUD/TopBarRoot/TimerBox/LabelTimer
@onready var label_victim = $HUD/TopBarRoot/VictimBox/LabelVictim
@onready var label_dps    = $HUD/TopBarRoot/DPSBox/LabelDPS

# ===============================
# BUTTONS
# ===============================
@onready var btn_pause   = $HUD/TopBarRoot/BtnPause
@onready var btn_mission = $HUD/TopBarRoot/BtnMission

# ===============================
# PANELS
# ===============================
@onready var mission_panel = $ComputerUI

var _timer_accum := 0.0
var pause_panel: CanvasLayer

# ===============================
# READY
# ===============================
func _ready():
    mission_panel.visible = false

    # LOAD PAUSE MENU SCENE
    var pause_scene: PackedScene = load("res://scenes/menus/PauseMenu.tscn")
    pause_panel = pause_scene.instantiate()
    add_child(pause_panel)
    pause_panel.visible = false

    btn_pause.pressed.connect(_on_pause_pressed)
    btn_mission.pressed.connect(_on_mission_pressed)

    _update_hud()


# ===============================
# TIMER
# ===============================
func _process(delta):
    if get_tree().paused:
        return

    if Global.time_left <= 0:
        return

    _timer_accum += delta
    if _timer_accum >= 1.0:
        _timer_accum = 0.0
        Global.time_left -= 1
        _update_hud()

# ===============================
# HUD UPDATE
# ===============================
func _update_hud():
    label_timer.text = _format_time(Global.time_left)

    if Global.current_mission.has("total_victim"):
        label_victim.text = "%d / %d" % [
            Global.victim_saved,
            Global.current_mission.total_victim
        ]
    else:
        label_victim.text = "0 / 0"

    label_dps.text = str(Global.decision_points)

# ===============================
# BUTTON ACTIONS
# ===============================
func _on_pause_pressed():
    var state: bool = not pause_panel.visible
    pause_panel.visible = state
    mission_panel.visible = false
    get_tree().paused = state

func _on_mission_pressed():
    mission_panel.visible = true
    pause_panel.visible = false
    get_tree().paused = true

# ===============================
# UTIL
# ===============================
func _format_time(sec: int) -> String:
    var m := sec / 60
    var s := sec % 60
    return "%02d:%02d" % [m, s]
