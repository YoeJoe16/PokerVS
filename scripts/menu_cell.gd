class_name MenuCell
extends Node2D

const LOOP_SECONDS := 12.0
const BREATH = [0, 1, 2, 1]
const LEAKS = [
	{"source": Vector2(69, 76), "floor_y": 347.0, "period": 2.0, "offset": 0.0},
	{"source": Vector2(201, 90), "floor_y": 323.0, "period": 3.0, "offset": 0.8},
	{"source": Vector2(27, 117), "floor_y": 298.0, "period": 4.0, "offset": 1.7}
]
@onready var body: Sprite2D = $SeatedBody
@onready var head: Sprite2D = $Head
var elapsed := 0.0
var playing := true

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	update_pose()

func set_active(value: bool) -> void:
	playing = value
	visible = value
	set_process(value)

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if not playing:
		return
	elapsed = fposmod(elapsed + delta, LOOP_SECONDS)
	update_pose()
	queue_redraw()

func look_direction() -> int:
	if (elapsed >= 1.5 and elapsed < 3.5) or (elapsed >= 9.2 and elapsed < 10.6):
		return -1
	if elapsed >= 5.0 and elapsed < 7.0:
		return 1
	return 0

func update_pose() -> void:
	var breath_frame := int(elapsed / 0.75) % 4
	var direction := look_direction()
	var blink := (elapsed > 1.2 and elapsed < 1.36) or (elapsed > 6.4 and elapsed < 6.56)
	body.frame = breath_frame
	head.frame = (direction + 1) * 2 + int(blink)
	# Feet/hips stay planted; body frames move shoulders and crossed arms.
	# The head moves independently with its gaze as well as with breathing.
	head.position = Vector2(110 + direction, 178 + BREATH[breath_frame])

static func drop_state(index: int, time: float) -> Dictionary:
	var leak: Dictionary = LEAKS[index]
	var phase: float = fposmod(time + leak.offset, leak.period) / leak.period
	var source: Vector2 = leak.source
	if phase < 0.18:
		return {"kind": "forming", "position": source, "progress": phase / 0.18}
	if phase < 0.70:
		var fall: float = (phase - 0.18) / 0.52
		return {"kind": "falling", "position": source.lerp(Vector2(source.x, leak.floor_y), fall * fall).round(), "progress": fall}
	if phase < 0.95:
		return {"kind": "splash", "position": Vector2(source.x, leak.floor_y), "progress": (phase - 0.70) / 0.25}
	return {"kind": "rest", "position": source, "progress": 0.0}

func _draw() -> void:
	for index in LEAKS.size():
		var drop := drop_state(index, elapsed)
		var point: Vector2 = drop.position
		match drop.kind:
			"forming":
				draw_rect(Rect2(point, Vector2(1, 1 + int(drop.progress * 2))), Color("95beb6"))
			"falling":
				draw_rect(Rect2(point, Vector2(1, 4)), Color("aad0c8"))
				draw_rect(Rect2(point + Vector2(-1, 3), Vector2(3, 2)), Color("739a9d"))
			"splash":
				var spread := int(2 + drop.progress * 10)
				var rise := roundf(sin(drop.progress * PI) * 5)
				for side in [-1, 1]:
					draw_rect(Rect2(point + Vector2(side * spread, -rise), Vector2(2, 1)), Color("8ab5af"))
					draw_rect(Rect2(point + Vector2(side * (spread - 1), 2), Vector2(3, 1)), Color("4c727c"))
				draw_line(point + Vector2(-spread, 0), point + Vector2(spread, 0), Color("5a8589"), 1, false)
