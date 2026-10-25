class_name OpeningComic
extends Node2D

signal reveal_menu
signal finished

const UI = preload("res://scripts/pixel_ui.gd")
const PanelArt = preload("res://scripts/intro_panel.gd")
const PANEL_INTERVAL := 3.0
const REVEAL_SECONDS := 0.8
const READ_SECONDS := 1.2
const FADE_SECONDS := 0.5
const COUNTS = [3, 3, 2]
const THREE = [
	[Vector2(0, 0), Vector2(240, 0), Vector2(240, 106), Vector2(0, 154)],
	[Vector2(0, 158), Vector2(240, 110), Vector2(240, 294), Vector2(0, 250)],
	[Vector2(0, 254), Vector2(240, 298), Vector2(240, 400), Vector2(0, 400)]
]
const TWO = [
	[Vector2(0, 0), Vector2(240, 0), Vector2(240, 178), Vector2(0, 220)],
	[Vector2(0, 224), Vector2(240, 182), Vector2(240, 400), Vector2(0, 400)]
]
var page := 0
var elapsed := 0.0
var phase := "panels"
var fade := 0.0
var ready_to_continue := false
var masks: Array[Polygon2D] = []
var panels: Array[IntroPanel] = []
@onready var art: Node2D = $Art
@onready var next_button: Button = $Next
@onready var transition: ColorRect = $Transition

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	next_button.theme = preload("res://assets/pixel/ui_theme.tres")
	next_button.add_theme_stylebox_override("normal", UI.box(Color("b3d3c2")))
	next_button.add_theme_stylebox_override("focus", UI.box(Color("efd496")))
	next_button.pressed.connect(request_next)
	load_page()

func load_page() -> void:
	for child in art.get_children():
		art.remove_child(child)
		child.queue_free()
	masks.clear()
	panels.clear()
	elapsed = 0.0
	ready_to_continue = false
	next_button.hide()
	next_button.disabled = true
	if page >= COUNTS.size():
		return
	var shapes: Array = TWO if page == 2 else THREE
	var origins: Array = [0, 182] if page == 2 else [0, 110, 260]
	for index in COUNTS[page]:
		var mask := Polygon2D.new()
		mask.polygon = PackedVector2Array(shapes[index])
		mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		art.add_child(mask)
		var panel := PanelArt.new()
		panel.page = page
		panel.panel = index
		panel.position.y = origins[index]
		mask.add_child(panel)
		masks.append(mask)
		panels.append(panel)
	update_panels()

func panel_alpha(index: int) -> float:
	return clampf((elapsed - index * PANEL_INTERVAL) / REVEAL_SECONDS, 0, 1)

func page_duration() -> float:
	return (COUNTS[page] - 1) * PANEL_INTERVAL + REVEAL_SECONDS + READ_SECONDS

func update_panels() -> void:
	for index in panels.size():
		masks[index].modulate.a = panel_alpha(index)
		panels[index].clock = maxf(0, elapsed - index * PANEL_INTERVAL)
		panels[index].queue_redraw()

func request_next() -> void:
	if phase != "panels" or not ready_to_continue:
		return
	phase = "out"
	fade = 0.0
	ready_to_continue = false
	next_button.disabled = true
	next_button.hide()
	transition.show()

func _process(delta: float) -> void:
	# Returning from an Android background pause must not skip unseen panels.
	advance(minf(delta, 0.1))

func advance(delta: float) -> void:
	if phase == "done":
		return
	if phase == "panels":
		elapsed += maxf(0, delta)
		update_panels()
		if not ready_to_continue and elapsed >= page_duration():
			ready_to_continue = true
			next_button.text = "CONTINUAR"
			next_button.disabled = false
			next_button.show()
			next_button.grab_focus()
	else:
		fade = minf(1.0, fade + maxf(0, delta) / FADE_SECONDS)
		transition.color.a = fade if phase == "out" else 1.0 - fade
		if fade >= 1.0:
			if phase == "out":
				page += 1
				load_page()
				if page == COUNTS.size():
					reveal_menu.emit()
				phase = "in"
				fade = 0.0
			else:
				transition.hide()
				if page == COUNTS.size():
					stop()
					finished.emit()
				else:
					phase = "panels"
	queue_redraw()

func stop() -> void:
	phase = "done"
	hide()
	set_process(false)
	next_button.disabled = true

func _draw() -> void:
	if page >= COUNTS.size():
		return
	draw_rect(Rect2(0, 0, 480, 900), Color("111a2b"))
	UI.text(self, "%d / 3" % (page + 1), Vector2(24, 846), 16, Color("93bcae"))
	if not ready_to_continue:
		var current := mini(COUNTS[page], int(elapsed / PANEL_INTERVAL) + 1)
		UI.text(self, "VIÑETA %d / %d" % [current, COUNTS[page]], Vector2(24, 874), 16, Color("87988c"))
