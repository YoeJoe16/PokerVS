extends Node2D

const Gestures = preload("res://scripts/gestures.gd")
const NAMES = ["Fuego", "Rayo", "Escudo", "Curación", "Hielo", "Explosión"]
const DESCRIPTIONS = ["28 de daño · 1.4 s", "42 de daño · 2.8 s", "+24 barrera · 4 s", "+26 vida · 6 s", "16 daño + frena · 3 s", "60 de daño · 5 s"]
const COLORS = [Color("ff9466"), Color("ffdb77"), Color("83b8ff"), Color("8de9b0"), Color("7be8ed"), Color("d7a0ff")]
const COOLDOWNS = [1.4, 2.8, 4.0, 6.0, 3.0, 5.0]
var equipped: Array = [0, 1, 2]
var owned: Array = [0, 1, 2]
var cooldown: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var state := "menu"
var hp := 100
var shield := 0
var coins := 0
var battle := 1
var enemy_hp := 80
var enemy_max := 80
var attack_timer := 4.0
var frozen := 0.0
var clock := 0.0
var flash := 0.0
var flash_color := Color.WHITE
var message := "Dibuja magia. Sobrevive. Elige tu camino."
var stroke: Array = []
var drawing := false
var selected_slot := 0
var controls: Array[Button] = []
var font := ThemeDB.fallback_font

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("101526"))
	build_buttons()

func button(label: String, rect: Rect2, action: Callable, disabled := false) -> void:
	var node := Button.new()
	node.text = label
	node.position = rect.position
	node.size = rect.size
	node.disabled = disabled
	node.add_theme_font_size_override("font_size", 17)
	node.pressed.connect(action)
	add_child(node)
	controls.append(node)

func build_buttons() -> void:
	for node in controls:
		node.queue_free()
	controls.clear()
	if state == "menu":
		button("COMENZAR EXPEDICIÓN", Rect2(50, 695, 380, 60), new_run)
	elif state == "shop":
		for slot in 3:
			var slot_id := slot
			button("%d · %s" % [slot + 1, NAMES[equipped[slot]]], Rect2(16 + slot * 154, 153, 146, 48), func(): selected_slot = slot_id; build_buttons())
		for id in 6:
			var spell_id := id
			var label: String = "Equipar" if id in owned else "Comprar · 35"
			if id == equipped[selected_slot]:
				label = "Equipado"
			button(label, Rect2(306, 240 + id * 75, 158, 46), func(): select_spell(spell_id), (id not in owned and coins < 35) or id == equipped[selected_slot])
		button("SIGUIENTE COMBATE", Rect2(30, 752, 420, 56), start_battle)
	elif state in ["dead", "victory"]:
		button("VOLVER A INTENTAR" if state == "dead" else "NUEVA EXPEDICIÓN", Rect2(45, 650, 390, 60), new_run)

func new_run() -> void:
	hp = 100
	shield = 0
	coins = 0
	battle = 1
	owned = [0, 1, 2]
	equipped = [0, 1, 2]
	start_battle()

func start_battle() -> void:
	state = "fight"
	enemy_max = 70 + battle * 20 if battle < 5 else 260
	enemy_hp = enemy_max
	attack_timer = 4.0
	frozen = 0
	cooldown.fill(0.0)
	stroke.clear()
	drawing = false
	message = "Un solo trazo. Empieza en el punto y suelta para lanzar."
	build_buttons()

func select_spell(id: int) -> void:
	if id not in owned:
		if coins < 35:
			return
		coins -= 35
		owned.append(id)
	var previous: int = equipped[selected_slot]
	var other := equipped.find(id)
	if other >= 0:
		equipped[other] = previous
	equipped[selected_slot] = id
	build_buttons()

func _process(delta: float) -> void:
	clock += delta
	flash = maxf(0, flash - delta)
	if state == "fight":
		for id in 6:
			cooldown[id] = maxf(0, cooldown[id] - delta)
		if frozen > 0:
			frozen -= delta
		else:
			attack_timer -= delta
		if attack_timer <= 0:
			var damage := 10 + battle * 2
			var blocked := mini(shield, damage)
			shield -= blocked
			hp = maxi(0, hp - damage + blocked)
			attack_timer = maxf(2.5, 4.2 - battle * 0.2)
			message = "¡Ataque enemigo! −%d vida" % (damage - blocked)
			flash = 0.3
			flash_color = Color("ff657c")
			if hp <= 0:
				state = "dead"
				drawing = false
				build_buttons()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if state != "fight":
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and Rect2(20, 465, 440, 340).has_point(event.position):
			drawing = true
			stroke = [event.position]
		elif not event.pressed and drawing:
			drawing = false
			var length := 0.0
			for i in range(1, stroke.size()):
				length += stroke[i - 1].distance_to(stroke[i])
			var id := Gestures.recognize(stroke, equipped) if length >= 55 else -1
			if id < 0:
				message = "Trazo no reconocido. Sigue el dibujo desde el punto."
			else:
				cast_spell(id)
			stroke.clear()
	elif event is InputEventMouseMotion and drawing:
		if Rect2(20, 465, 440, 340).has_point(event.position):
			if stroke[-1].distance_to(event.position) > 3:
				stroke.append(event.position)
		else:
			drawing = false
			stroke.clear()
			message = "Mantén el trazo dentro del panel."

func cast_spell(id: int) -> void:
	if state != "fight" or id not in equipped:
		return
	if cooldown[id] > 0:
		message = "%s se está recargando." % NAMES[id]
		return
	cooldown[id] = COOLDOWNS[id]
	flash = 0.45
	flash_color = COLORS[id]
	message = "¡%s!" % NAMES[id]
	match id:
		0: enemy_hp -= 28
		1: enemy_hp -= 42
		2: shield = mini(48, shield + 24)
		3: hp = mini(100, hp + 26)
		4:
			enemy_hp -= 16
			frozen = 2.5
		5: enemy_hp -= 60
	if enemy_hp <= 0:
		coins += 35 + battle * 5
		hp = mini(100, hp + 12)
		state = "victory" if battle == 5 else "shop"
		battle += 1
		selected_slot = 0
		drawing = false
		build_buttons()

func text(value: String, pos: Vector2, size := 20, color := Color("e9edf8")) -> void:
	draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func panel(rect: Rect2, color := Color("1d263d")) -> void:
	draw_style_box(style(color), rect)

func style(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(16)
	return box

func glyph(id: int, origin: Vector2, size: float, color: Color) -> void:
	var points := PackedVector2Array()
	for point in Gestures.templates()[id]:
		points.append(origin + point * size)
	draw_polyline(points, color, 3.5, true)
	draw_circle(points[0], 5, Color.WHITE)

func bar(rect: Rect2, ratio: float, color: Color) -> void:
	panel(rect, Color("293149"))
	if ratio > 0:
		panel(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y)), color)

func _draw() -> void:
	for i in 16:
		draw_circle(Vector2(25 + (i * 73) % 440, 60 + (i * 137) % 800), 1.5, Color("455272"))
	if state == "menu":
		text("R U N A   /   A R E N A", Vector2(45, 126), 32, Color("a5c2ff"))
		text("Magia al alcance de tus dedos", Vector2(48, 167), 23)
		panel(Rect2(30, 215, 420, 420))
		text("01   ELIGE TUS TRES HECHIZOS", Vector2(50, 260), 20)
		for id in 3:
			glyph(id, Vector2(65 + id * 135, 295), 65, COLORS[id])
		text("02   DIBUJA PARA LANZAR", Vector2(50, 422), 20)
		text("Un trazo, desde el punto blanco.", Vector2(50, 457), 20)
		text("03   COMBATE · COMPRA · MEJORA", Vector2(50, 517), 19)
		text("Supera 4 guardianes y al jefe final.", Vector2(50, 554), 20)
		text("Las monedas y compras duran esta partida.", Vector2(50, 595), 16, Color("a0aec9"))
		text("Prototipo · Táctil y ratón", Vector2(120, 800), 18)
	elif state == "fight":
		text("JEFE FINAL" if battle == 5 else "GUARDIÁN %d / 4" % battle, Vector2(20, 36), 22)
		text("%d monedas" % coins, Vector2(335, 35), 18, Color("ffdb77"))
		bar(Rect2(20, 55, 300, 13), hp / 100.0, Color("8de9b0"))
		text("Vida %d / 100    Barrera %d" % [hp, shield], Vector2(20, 92), 18)
		for slot in 3:
			var id: int = equipped[slot]
			var x := 16 + slot * 154
			panel(Rect2(x, 110, 146, 130))
			glyph(id, Vector2(x + 48, 125), 50, COLORS[id] if cooldown[id] <= 0 else Color("65708b"))
			text(NAMES[id], Vector2(x + 12, 202), 19, COLORS[id])
			text("Listo" if cooldown[id] <= 0 else "%.1f s" % cooldown[id], Vector2(x + 12, 225), 16)
		var enemy_color := Color("7be8ed") if frozen > 0 else Color("b595e5")
		var center := Vector2(240, 332 + sin(clock * 2) * 5)
		draw_circle(center, 48 + (8 if battle == 5 else 0), Color("2c2445"))
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -42), center + Vector2(38, 20), center + Vector2(0, 40), center + Vector2(-38, 20)]), enemy_color)
		draw_circle(center + Vector2(-12, 0), 5, Color("101526"))
		draw_circle(center + Vector2(12, 0), 5, Color("101526"))
		bar(Rect2(100, 400, 280, 12), enemy_hp / float(enemy_max), enemy_color)
		text("%d / %d" % [maxi(0, enemy_hp), enemy_max], Vector2(200, 437), 17)
		panel(Rect2(20, 465, 440, 340), Color("192236"))
		draw_rect(Rect2(26, 471, 428, 328), Color("435779"), false, 1)
		text("ZONA DE TRAZO", Vector2(160, 503), 18, Color("7283a6"))
		text("Dibuja aquí y suelta", Vector2(144, 660), 20, Color("7283a6"))
		if stroke.size() > 1:
			draw_polyline(PackedVector2Array(stroke), Color("c4dcff"), 6, true)
		if not stroke.is_empty():
			draw_circle(stroke[0], 6, Color.WHITE)
		text("Congelado" if frozen > 0 else "Ataque en %.1f s" % maxf(0, attack_timer), Vector2(155, 780), 20, Color("ffdb77"))
		text(message, Vector2(15, 840), 15)
		text("Tres runas · Una oportunidad", Vector2(118, 878), 17, Color("7283a6"))
	elif state == "shop":
		text("EL REFUGIO", Vector2(25, 52), 30, Color("a5c2ff"))
		text("Victoria: +monedas y 12 de vida", Vector2(25, 90), 20)
		text("%d monedas · Vida %d · Próxima pelea %d/5" % [coins, hp, battle], Vector2(25, 121), 18, Color("ffdb77"))
		text("Elige un espacio; luego compra o equipa.", Vector2(25, 226), 18)
		for id in 6:
			var y := 248 + id * 75
			glyph(id, Vector2(25, y), 32, COLORS[id])
			text(NAMES[id], Vector2(76, y + 13), 20, COLORS[id])
			text(DESCRIPTIONS[id], Vector2(76, y + 39), 15)
		text("Espacio seleccionado: %d" % (selected_slot + 1), Vector2(30, 725), 18, Color("ffdb77"))
		text("Sin duplicados: al equipar se intercambian.", Vector2(30, 850), 16, Color("a0aec9"))
	else:
		text("EXPEDICIÓN COMPLETADA" if state == "victory" else "LA MAGIA SE APAGÓ", Vector2(25, 260), 29, Color("a5c2ff"))
		text("Derrotaste al guardián del portal." if state == "victory" else "Cada trazo es una nueva oportunidad.", Vector2(30, 320), 22)
		text("Monedas restantes: %d" % coins, Vector2(30, 375), 22, Color("ffdb77"))
		text("Prueba otra combinación de hechizos.", Vector2(30, 430), 21)
	if flash > 0 and state == "fight":
		draw_rect(Rect2(0, 0, 480, 900), Color(flash_color, flash * 0.18))
