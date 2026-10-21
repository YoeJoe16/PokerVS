extends Node2D

const Campaign = preload("res://scripts/campaign.gd")
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
var encounter: Dictionary = {}
var enemy_ward := 0
var attack_count := 0
var enraged := false
var last_reward := 0
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
	RenderingServer.set_default_clear_color(Color("111a21"))
	build_buttons()

func button(label: String, rect: Rect2, action: Callable, disabled := false) -> void:
	var node := Button.new()
	node.text = label
	node.position = rect.position
	node.size = rect.size
	node.disabled = disabled
	node.add_theme_font_size_override("font_size", 17)
	node.add_theme_stylebox_override("normal", style(Color("294842")))
	node.add_theme_stylebox_override("hover", style(Color("39665c")))
	node.add_theme_stylebox_override("pressed", style(Color("477e6b")))
	node.add_theme_stylebox_override("disabled", style(Color("27323a")))
	node.pressed.connect(action)
	add_child(node)
	controls.append(node)

func build_buttons() -> void:
	for node in controls:
		node.queue_free()
	controls.clear()
	if state == "menu":
		button("INICIAR LA FUGA", Rect2(50, 695, 380, 60), new_run)
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
		button("VOLVER A INTENTAR" if state == "dead" else "NUEVO INTENTO", Rect2(45, 650, 390, 60), new_run)

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
	encounter = Campaign.encounter(battle)
	enemy_max = encounter.hp
	enemy_ward = 20 if encounter.pattern == "ward" else 0
	attack_count = 0
	enraged = false
	enemy_hp = enemy_max
	attack_timer = encounter.interval
	frozen = 0
	cooldown.fill(0.0)
	stroke.clear()
	drawing = false
	message = encounter.quote
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
			var damage := next_damage()
			attack_count += 1
			var blocked := mini(shield, damage)
			shield -= blocked
			hp = maxi(0, hp - damage + blocked)
			attack_timer = next_interval()
			message = "¡Magia clandestina! −%d vida" % (damage - blocked)
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
	var health_before := enemy_hp
	match id:
		0: enemy_hp -= 28
		1: enemy_hp -= 42
		2: shield = mini(48, shield + 24)
		3: hp = mini(100, hp + 26)
		4:
			enemy_hp -= 16
			frozen = 2.5
		5: enemy_hp -= 60
	var damage_dealt := health_before - enemy_hp
	var absorbed := mini(enemy_ward, damage_dealt)
	enemy_ward -= absorbed
	enemy_hp += absorbed
	if encounter.pattern == "elite" and not enraged and enemy_hp > 0 and enemy_hp <= enemy_max / 2:
		enraged = true
		attack_timer = minf(attack_timer, 2.5)
		message = "¡Mazas entra en furia! Sus ataques se aceleran."
	if enemy_hp <= 0:
		last_reward = 35 + battle * 5 + (20 if battle % 5 == 0 else 0)
		coins += last_reward
		hp = mini(100, hp + 12)
		state = "victory" if battle == Campaign.PLAYABLE_LEVELS else "shop"
		battle += 1
		selected_slot = 0
		drawing = false
		build_buttons()

func next_damage() -> int:
	if encounter.pattern == "elite" and attack_count % 2 == 1:
		return 26
	return encounter.damage

func next_interval() -> float:
	if encounter.pattern == "double" and attack_count % 2 == 1:
		return 0.8
	return encounter.interval * (0.7 if enraged else 1.0)

func prison_background() -> void:
	draw_rect(Rect2(0, 0, 480, 900), Color("111a21"))
	for y in range(270, 466, 48):
		draw_line(Vector2(0, y), Vector2(480, y), Color("26353b"), 1)
	for x in [10, 350]:
		draw_rect(Rect2(x, 282, 120, 110), Color("0b1119"))
		for offset in range(12, 120, 23):
			draw_line(Vector2(x + offset, 282), Vector2(x + offset, 392), Color("415058"), 5)
		draw_line(Vector2(x, 350), Vector2(x + 120, 350), Color("415058"), 4)
	draw_rect(Rect2(155, 277, 170, 5), Color("a5dfd5"))
	draw_line(Vector2(0, 458), Vector2(480, 458), Color("527c77"), 2)
	# Security camera with a rune lens: modern prison, arcane surveillance.
	draw_line(Vector2(425, 259), Vector2(425, 276), Color("718282"), 3)
	draw_rect(Rect2(409, 270, 28, 12), Color("718282"))
	draw_circle(Vector2(409, 276), 4, Color("85f4d4"))

func prisoner(center: Vector2, tint: Color, elite: bool) -> void:
	var width := 34.0 if elite else 26.0
	draw_set_transform(center, 0, Vector2.ONE)
	var shadow := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24.0
		shadow.append(Vector2(cos(angle) * (width + 15), 56 + sin(angle) * 8))
	draw_colored_polygon(shadow, Color("090f16"))
	draw_line(Vector2(-13, 30), Vector2(-17, 54), Color("303d48"), 13)
	draw_line(Vector2(13, 30), Vector2(17, 54), Color("303d48"), 13)
	draw_style_box(style(tint.darkened(0.2)), Rect2(-width, -12, width * 2, 48))
	draw_line(Vector2(-width, -2), Vector2(-width - 14, 22), tint, 12)
	draw_line(Vector2(width, -2), Vector2(width + 17, 6), tint, 12)
	draw_circle(Vector2(0, -29), 17, Color("bd947f"))
	draw_arc(Vector2(0, -32), 17, PI, TAU, 12, Color("28323a"), 7, true)
	draw_line(Vector2(-8, -29), Vector2(-3, -29), Color("182129"), 2)
	draw_line(Vector2(4, -29), Vector2(9, -29), Color("182129"), 2)
	draw_rect(Rect2(-14, 3, 28, 5), Color("d9d3b8"))
	draw_circle(Vector2(width + 22, 0), 10 + sin(clock * 4) * 2, Color(tint, 0.3))
	glyph(1 if elite else (battle - 1) % 3, Vector2(width + 15, -8), 16, Color("b6f9de"))
	draw_set_transform(Vector2.ZERO)

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
	prison_background()
	if state == "menu":
		text("F U G A   /   R Ú N I C A", Vector2(45, 126), 32, Color("a5c2ff"))
		text("Un aprendiz. Una condena equivocada.", Vector2(35, 167), 22)
		panel(Rect2(30, 215, 420, 420))
		text("01   TRES RUNAS PARA ESCAPAR", Vector2(50, 260), 20)
		for id in 3:
			glyph(id, Vector2(65 + id * 135, 295), 65, COLORS[id])
		text("02   DIBUJA PARA LANZAR", Vector2(50, 422), 20)
		text("Un trazo, desde el punto blanco.", Vector2(50, 457), 20)
		text("03   GÁNATE EL PASO POR EL BLOQUE", Vector2(45, 517), 18)
		text("Cinco presos. El último controla el corredor.", Vector2(45, 554), 17)
		text("Un malentendido. Nadie quiere escucharte.", Vector2(45, 595), 16, Color("a0aec9"))
		text("Bloque 01 · Niveles 1–5 de 15", Vector2(105, 800), 18)
	elif state == "fight":
		text("BLOQUE 01 · NIVEL %02d / 15" % battle, Vector2(20, 36), 19)
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
		var enemy_color: Color = Color("7be8ed") if frozen > 0 else encounter.color
		text(encounter.name + (" · ÉLITE" if battle == 5 else ""), Vector2(22, 264), 20, enemy_color)
		prisoner(Vector2(240, 333), enemy_color, battle == 5)
		bar(Rect2(100, 400, 280, 12), enemy_hp / float(enemy_max), enemy_color)
		text("%d / %d%s" % [maxi(0, enemy_hp), enemy_max, " · Barrera %d" % enemy_ward if enemy_ward > 0 else ""], Vector2(145, 434), 16)
		text(encounter.hint, Vector2(25, 454), 14, Color("b4c8cb"))
		panel(Rect2(20, 465, 440, 340), Color("192236"))
		draw_rect(Rect2(26, 471, 428, 328), Color("435779"), false, 1)
		text("MAGIA CLANDESTINA", Vector2(140, 503), 18, Color("7283a6"))
		text("Dibuja aquí y suelta", Vector2(144, 660), 20, Color("7283a6"))
		if stroke.size() > 1:
			draw_polyline(PackedVector2Array(stroke), Color("c4dcff"), 6, true)
		if not stroke.is_empty():
			draw_circle(stroke[0], 6, Color.WHITE)
		text("Congelado" if frozen > 0 else "%s · %.1f s" % ["Golpe cargado" if next_damage() == 26 else "Ataque", maxf(0, attack_timer)], Vector2(110, 780), 19, Color("ffdb77"))
		text(message, Vector2(15, 840), 15)
		text("Furia activa" if enraged else "Bloque de celdas · Presos", Vector2(118, 878), 17, Color("7283a6"))
	elif state == "shop":
		text("CONTRABANDO", Vector2(25, 52), 30, Color("a5c2ff"))
		text("Victoria: +%d monedas · +12 vida" % last_reward, Vector2(25, 90), 20)
		text("%d monedas · Vida %d · Próximo nivel %d/15" % [coins, hp, battle], Vector2(25, 121), 18, Color("ffdb77"))
		text("Elige un espacio; luego compra o equipa.", Vector2(25, 226), 18)
		for id in 6:
			var y := 248 + id * 75
			glyph(id, Vector2(25, y), 32, COLORS[id])
			text(NAMES[id], Vector2(76, y + 13), 20, COLORS[id])
			text(DESCRIPTIONS[id], Vector2(76, y + 39), 15)
		text("Espacio seleccionado: %d" % (selected_slot + 1), Vector2(30, 725), 18, Color("ffdb77"))
		text("Sin duplicados: al equipar se intercambian.", Vector2(30, 850), 16, Color("a0aec9"))
	else:
		text("CORREDOR DESPEJADO" if state == "victory" else "LA FUGA TERMINÓ", Vector2(25, 260), 29, Color("a5c2ff"))
		text("Mazas cae. La puerta del patio sigue lejos." if state == "victory" else "Cada trazo es una nueva oportunidad.", Vector2(25, 320), 20)
		text("Monedas restantes: %d" % coins, Vector2(30, 375), 22, Color("ffdb77"))
		text("Fin de la demo · Niveles 1–5 del bloque.", Vector2(25, 430), 20)
		text("Quedan diez niveles antes del jefe de etapa.", Vector2(25, 469), 18)
		text("Ruta prevista: 5 etapas de 15 niveles.", Vector2(25, 510), 18, Color("a0aec9"))
	if flash > 0 and state == "fight":
		draw_rect(Rect2(0, 0, 480, 900), Color(flash_color, flash * 0.18))
