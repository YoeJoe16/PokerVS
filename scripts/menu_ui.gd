extends Node2D

const UI = preload("res://scripts/pixel_ui.gd")
const Gestures = preload("res://scripts/gestures.gd")
@onready var game: Node2D = get_parent()

func text(value: String, position: Vector2, size := 16, color := Color("dfd8bd")) -> void:
	UI.text(self, value, position, size, color, 392)

func lines(values: Array, y: float) -> void:
	for value in values:
		text(value, Vector2(44, y))
		y += 28

func glyph(id: int, origin: Vector2, size: float) -> void:
	var points := PackedVector2Array()
	for point in Gestures.templates()[id]:
		points.append((origin + point * size).snapped(Vector2(2, 2)))
	draw_polyline(points, game.COLORS[id], 4, false)
	draw_rect(Rect2(points[0] - Vector2(4, 4), Vector2(8, 8)), Color.WHITE)

func spell_cards(ids: Array, y: float) -> void:
	for slot in ids.size():
		var id: int = ids[slot]
		var x := 40 + slot * 136
		draw_style_box(UI.box(), Rect2(x, y, 128, 124))
		glyph(id, Vector2(x + 40, y + 22), 46)
		text(game.NAMES[id], Vector2(x + 16, y + 100), 16, game.COLORS[id])

func _draw() -> void:
	if game.state not in ["menu", "tutorial"]:
		return
	# The title floats over the animation without a large banner or story text.
	text("FUGA RÚNICA", Vector2(26, 66), 32, Color("0d1725"))
	text("FUGA RÚNICA", Vector2(24, 64), 32, Color("eddbab"))
	draw_rect(Rect2(24, 78, 108, 2), Color("91b7a6"))
	if game.state != "tutorial":
		return
	draw_rect(Rect2(0, 96, 480, 702), Color(0.04, 0.07, 0.11, 0.7))
	draw_style_box(UI.box(), Rect2(20, 112, 440, 660))
	text("CÓMO JUGAR", Vector2(44, 160), 32, Color("eddbab"))
	text("%d / 3" % (game.tutorial_page + 1), Vector2(366, 158), 16, Color("93bcae"))
	draw_rect(Rect2(40, 178, 400, 2), Color("435e69"))
	match game.tutorial_page:
		0:
			text("01 / DIBUJA PARA LANZAR", Vector2(44, 212), 16, Color("eddbab"))
			spell_cards([0, 1, 2], 238)
			lines([
				"LLEVAS TRES HECHIZOS EQUIPADOS.",
				"SUS SÍMBOLOS APARECEN EN EL HUD.",
				"EMPIEZA EN EL PUNTO BLANCO.",
				"DIBUJA UN SOLO TRAZO EN EL PANEL.",
				"LEVANTA EL DEDO PARA LANZAR.",
				"RESPETA EL SENTIDO DEL SÍMBOLO.",
				"EL TAMAÑO DEL DIBUJO PUEDE VARIAR."
			], 408)
			text("DEDO EN ANDROID / RATÓN EN PC", Vector2(44, 710), 16, Color("93bcae"))
		1:
			text("02 / ATAQUE, DEFENSA Y RECARGA", Vector2(44, 212), 16, Color("eddbab"))
			spell_cards([2, 3, 4], 238)
			lines([
				"EL COMBATE SIGUE MIENTRAS DIBUJAS.",
				"LA CUENTA ATRÁS ANUNCIA EL ATAQUE.",
				"ESCUDO ABSORBE DAÑO RECIBIDO.",
				"CURACIÓN RECUPERA TU VIDA.",
				"HIELO RETRASA LOS ATAQUES.",
				"CADA HECHIZO TIENE SU RECARGA.",
				"ESPERA A VER LISTO PARA REPETIRLO."
			], 408)
			text("COMBINA ATAQUES Y PROTECCIÓN", Vector2(44, 710), 16, Color("93bcae"))
		2:
			text("03 / COMPRA Y EQUIPA", Vector2(44, 212), 16, Color("eddbab"))
			lines([
				"CADA VICTORIA DA MONEDAS Y VIDA.",
				"EN LA TIENDA, UN HECHIZO CUESTA 35.",
				"ELIGE UNO DE LOS TRES ESPACIOS.",
				"LUEGO COMPRA O EQUIPA UN HECHIZO.",
				"NO PUEDES LLEVAR DOS IGUALES.",
				"SI YA LO LLEVAS, CAMBIA DE ESPACIO."
			], 262)
			draw_rect(Rect2(44, 448, 392, 2), Color("435e69"))
			lines([
				"ESTA DEMO INCLUYE CINCO COMBATES.",
				"SIN VIDA, TERMINA EL INTENTO.",
				"AL REINICIAR PIERDES LAS MONEDAS",
				"Y LOS HECHIZOS QUE COMPRASTE."
			], 492)
			text("YA PUEDES COMENZAR", Vector2(44, 710), 16, Color("93bcae"))
