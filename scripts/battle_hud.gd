extends Node2D

const UI = preload("res://scripts/pixel_ui.gd")

@onready var game: Node2D = get_parent()

func panel(rect: Rect2, color: Color) -> void:
	draw_style_box(game.style(color), rect)

func text(value: String, pos: Vector2, size: int, color := Color("e9edf8")) -> void:
	UI.text(self, value, pos, size, color, 228)

func bar(rect: Rect2, ratio: float, color: Color) -> void:
	draw_rect(rect, Color("38495a"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y)), color)

func _draw() -> void:
	if game.state not in ["fight", "resolving"]:
		return
	panel(Rect2(14, 214, 254, 67), Color("172638"))
	text(game.encounter.name, Vector2(24, 235), 16, Color("e9d3ac"))
	bar(Rect2(24, 247, 176, 8), maxf(0, game.enemy_hp) / float(game.enemy_max), Color("dca588"))
	text("%d" % maxi(0, game.enemy_hp), Vector2(211, 256), 14)
	text("JEFE" if game.encounter.pattern == "boss" else ("ÉLITE" if game.encounter.pattern == "elite" else "PRESO"), Vector2(24, 273), 12, Color("b0b9b8"))
	if game.enemy_ward > 0:
		text("Barrera %d" % game.enemy_ward, Vector2(95, 273), 12)
	panel(Rect2(216, 396, 250, 84), Color("172638"))
	text("Congelado" if game.frozen > 0 else ("Preparando curación" if game.enemy_spell_id() == 3 else ("Preparando barrera" if game.enemy_spell_id() == 2 else "Golpe: %d de daño" % game.next_damage())), Vector2(228, 418), 15, Color("e7c28f"))
	text("%.1f s" % maxf(0, game.attack_timer), Vector2(228, 443), 20)
	text("Lanzando…" if game.arena.player_spell >= 0 else "Dibuja abajo para lanzar", Vector2(228, 467), 14, Color("a5c9bc"))
