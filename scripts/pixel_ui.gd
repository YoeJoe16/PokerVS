class_name PixelUI
extends RefCounted

const FONT = preload("res://assets/pixel/rune_font.fnt")
const FRAME = preload("res://assets/pixel/ui_frame.png")
const WALL = preload("res://assets/pixel/ui_wall.png")

static func font_size(requested: int) -> int:
	# The bitmap's native size is 8. Integer scaling keeps every stroke crisp.
	if requested >= 40:
		return 48
	return 32 if requested >= 24 else 16

static func box(tint := Color.WHITE) -> StyleBoxTexture:
	var result := StyleBoxTexture.new()
	result.texture = FRAME
	result.modulate_color = tint
	for side in 4:
		result.set_texture_margin(side, 8)
		result.set_content_margin(side, 8)
	return result

static func text(canvas: CanvasItem, value: String, pos: Vector2, requested: int, color: Color, width: float = -1) -> void:
	var size := font_size(requested)
	var available := 464 - pos.x if width < 0 else width
	var shown := value
	# Fit single-line labels within their panel without fractional font scaling.
	if FONT.get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > available:
		while not shown.is_empty() and FONT.get_string_size(shown + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > available:
			shown = shown.left(-1)
		shown += "…"
	canvas.draw_string(FONT, pos.snapped(Vector2(2, 2)), shown, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
