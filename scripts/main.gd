extends Node2D

const UI = preload("res://scripts/pixel_ui.gd")
const Campaign = preload("res://scripts/campaign.gd")
const Gestures = preload("res://scripts/gestures.gd")
const Book = preload("res://scripts/spells.gd")
const NAMES = Book.NAMES
const DESCRIPTIONS = Book.DESCRIPTIONS
const COLORS = Book.COLORS
const COOLDOWNS = Book.COOLDOWNS
const DRAW_AREA = Rect2(20, 526, 440, 274)
@onready var arena: BattleArena = $BattleArena
@onready var menu_cell: MenuCell = $MenuCell
var tutorial_page := 0
var pending_outcome := ""
var equipped: Array = [0, 1, 2]
var owned: Array = [0, 1, 2]
var cooldown: Array = []
var shop_offers: Array = []
var shop_inventory := false
var inventory_page := 0
var shop_rng := RandomNumberGenerator.new()
var paralyzed := 0.0
var state := "intro"
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
var message := "Dibuja magia. Sobrevive. Elige tu camino."
var stroke: Array = []
var drawing := false
var selected_slot := 0
var controls: Array[Button] = []
var font = UI.FONT

func _ready() -> void:
	$Intro.reveal_menu.connect(reveal_intro_menu)
	$Intro.finished.connect(finish_intro)
	cooldown.resize(NAMES.size())
	cooldown.fill(0.0)
	shop_rng.randomize()
	RenderingServer.set_default_clear_color(Color("111a21"))
	build_buttons()

func button(label: String, rect: Rect2, action: Callable, disabled := false) -> void:
	var node := Button.new()
	node.theme = preload("res://assets/pixel/ui_theme.tres")
	node.z_index = 20
	node.text = label
	node.position = rect.position
	node.size = rect.size
	node.disabled = disabled
	node.add_theme_font_override("font", UI.FONT)
	node.add_theme_font_size_override("font_size", 16)
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_theme_color_override("font_color", Color("e4d5b0"))
	node.add_theme_color_override("font_disabled_color", Color("667c83"))
	node.add_theme_stylebox_override("focus", UI.box(Color("efd496")))
	node.add_theme_stylebox_override("normal", UI.box(Color("b3d3c2")))
	node.add_theme_stylebox_override("hover", UI.box(Color("def4cc")))
	node.add_theme_stylebox_override("pressed", UI.box(Color("86a3aa")))
	node.add_theme_stylebox_override("disabled", UI.box(Color("657780")))
	node.pressed.connect(action)
	add_child(node)
	controls.append(node)

func build_buttons() -> void:
	arena.visible = state in ["fight", "resolving"]
	menu_cell.set_active(state in ["menu", "tutorial", "intro_transition"])
	for node in controls:
		node.disabled = true
		node.queue_free()
	controls.clear()
	if state == "menu":
		button("CÓMO JUGAR", Rect2(20, 818, 152, 54), open_tutorial)
		button("INICIAR", Rect2(324, 818, 136, 54), new_run)
	elif state == "tutorial":
		button("CERRAR", Rect2(20, 818, 112, 54), close_tutorial)
		button("ANTERIOR", Rect2(148, 818, 136, 54), func(): change_tutorial_page(-1), tutorial_page == 0)
		if tutorial_page < 2:
			button("SIGUIENTE", Rect2(300, 818, 160, 54), func(): change_tutorial_page(1))
		else:
			button("INICIAR", Rect2(324, 818, 136, 54), new_run)
	elif state == "shop":
		for slot in 3:
			var slot_id := slot
			button("%d · %s" % [slot + 1, NAMES[equipped[slot]]], Rect2(16 + slot * 154, 153, 146, 48), func(): selected_slot = slot_id; build_buttons())
			if slot == selected_slot:
				controls[-1].add_theme_color_override("font_color", Color("ffe3a0"))
				controls[-1].add_theme_stylebox_override("normal", UI.box(Color("ffe3a0")))
		button("OFERTAS" if shop_inventory else "MIS RUNAS", Rect2(20, 208, 170, 36), toggle_inventory)
		if shop_inventory:
			button("<", Rect2(316, 208, 60, 36), func(): inventory_page = maxi(0, inventory_page - 1); build_buttons(), inventory_page == 0)
			button(">", Rect2(394, 208, 60, 36), func(): inventory_page += 1; build_buttons(), (inventory_page + 1) * 3 >= owned.size())
		var shown := shop_items()
		for row in shown.size():
			var id: int = shown[row]
			var label := "EQUIPAR" if id in owned else "%d MONEDAS" % Book.price(id)
			if id == equipped[selected_slot]:
				label = "EQUIPADO"
			button(label, Rect2(292, 266 + row * 148, 160, 42), func(): select_spell(id), (id not in owned and coins < Book.price(id)) or id == equipped[selected_slot])
		button("SIGUIENTE COMBATE", Rect2(30, 752, 420, 56), start_battle)
	elif state in ["dead", "victory"]:
		button("VOLVER A INTENTAR" if state == "dead" else "NUEVO INTENTO", Rect2(45, 650, 390, 60), new_run)

func reveal_intro_menu() -> void:
	state = "intro_transition"
	build_buttons()

func finish_intro() -> void:
	state = "menu"
	build_buttons()

func shop_items() -> Array:
	return owned.slice(inventory_page * 3, inventory_page * 3 + 3) if shop_inventory else shop_offers

func toggle_inventory() -> void:
	shop_inventory = not shop_inventory
	inventory_page = 0
	build_buttons()

func open_tutorial() -> void:
	if state != "menu":
		return
	tutorial_page = 0
	state = "tutorial"
	build_buttons()

func close_tutorial() -> void:
	if state != "tutorial":
		return
	state = "menu"
	build_buttons()

func change_tutorial_page(direction: int) -> void:
	tutorial_page = clampi(tutorial_page + direction, 0, 2)
	build_buttons()

func new_run() -> void:
	$Intro.stop()
	hp = 100
	shield = 0
	coins = 0
	battle = 1
	shop_offers.clear()
	shop_inventory = false
	inventory_page = 0
	owned = [0, 1, 2]
	equipped = [0, 1, 2]
	start_battle()

func start_battle() -> void:
	state = "fight"
	pending_outcome = ""
	arena.reset(battle - 1)
	encounter = Campaign.encounter(battle)
	enemy_max = encounter.hp
	enemy_ward = encounter.get("ward", 20 if encounter.pattern == "ward" else 0)
	attack_count = 0
	enraged = false
	enemy_hp = enemy_max
	attack_timer = encounter.interval
	frozen = 0
	paralyzed = 0
	cooldown.fill(0.0)
	stroke.clear()
	drawing = false
	message = encounter.quote
	build_buttons()

func select_spell(id: int) -> void:
	if state != "shop" or id < 0 or id >= NAMES.size():
		return
	if id not in owned:
		if id not in shop_offers or coins < Book.price(id):
			return
		coins -= Book.price(id)
		owned.append(id)
	var previous: int = equipped[selected_slot]
	var other := equipped.find(id)
	if other >= 0:
		equipped[other] = previous
	equipped[selected_slot] = id
	build_buttons()

func _process(delta: float) -> void:
	arena.opponent_frozen = frozen > 0
	arena.player_barrier = shield > 0
	arena.opponent_barrier = enemy_ward > 0
	if state == "resolving" and not arena.is_busy():
		state = pending_outcome
		if state == "shop":
			shop_offers = Book.offers(owned, shop_rng)
			shop_inventory = false
			inventory_page = 0
		pending_outcome = ""
		build_buttons()
	if state == "fight":
		paralyzed = maxf(0.0, paralyzed - delta)
		for id in NAMES.size():
			cooldown[id] = maxf(0, cooldown[id] - delta)
		if frozen > 0:
			frozen -= delta
		else:
			attack_timer -= delta
		if attack_timer <= 0:
			var damage := next_damage()
			var spell := enemy_spell_id()
			arena.play_spell(spell, false)
			if spell == 3:
				enemy_hp = mini(enemy_max, enemy_hp + 24)
			elif spell == 2:
				enemy_ward = mini(48, enemy_ward + 24)
			attack_count += 1
			var blocked := mini(shield, damage)
			shield -= blocked
			hp = maxi(0, hp - damage + blocked)
			attack_timer = next_interval()
			message = "El rival recupera 24 de vida." if spell == 3 else ("El rival levanta una barrera." if spell == 2 else "¡Magia clandestina! −%d vida" % (damage - blocked))
			if hp <= 0:
				state = "resolving"
				pending_outcome = "dead"
				arena.player_defeated = true
				drawing = false
				build_buttons()
	queue_redraw()
	$BattleHUD.queue_redraw()
	$MenuUI.queue_redraw()

func _input(event: InputEvent) -> void:
	if state != "fight" or paralyzed > 0:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and DRAW_AREA.has_point(event.position):
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
		if DRAW_AREA.has_point(event.position):
			if stroke[-1].distance_to(event.position) > 3:
				stroke.append(event.position)
		else:
			drawing = false
			stroke.clear()
			message = "Mantén el trazo dentro del panel."

func cast_spell(id: int) -> void:
	if state != "fight" or id not in equipped or paralyzed > 0:
		return
	if cooldown[id] > 0:
		message = "%s se está recargando." % NAMES[id]
		return
	arena.play_spell(id)
	cooldown[id] = COOLDOWNS[id]
	message = "¡%s!" % NAMES[id]
	var health_before := enemy_hp
	enemy_hp -= Book.DAMAGE[id]
	match id:
		2: shield = mini(48, shield + 24)
		3: hp = mini(100, hp + 26)
		4: frozen = maxf(frozen, 2.5)
		7: frozen = maxf(frozen, 0.6)
		8:
			hp = mini(100, hp + 18)
			shield = mini(48, shield + 12)
		10: frozen = maxf(frozen, 4.0)
		12:
			shield = 48
			hp = mini(100, hp + 20)
		14:
			hp = maxi(0, hp - 34)
			message = "¡Sangre! Sacrificas 34 de vida."
		15:
			paralyzed = 3.0
			drawing = false
			stroke.clear()
			message = "¡Vacío! No puedes lanzar durante 3 s."
	var damage_dealt := health_before - enemy_hp
	var absorbed := 0 if id == 9 else mini(enemy_ward, damage_dealt)
	enemy_ward -= absorbed
	enemy_hp += absorbed
	if encounter.pattern in ["elite", "boss"] and not enraged and enemy_hp > 0 and enemy_hp <= enemy_max / 2:
		enraged = true
		attack_timer = minf(attack_timer, 2.5)
		message = "¡Furia! El rival acelera sus ataques."
	# Sacrifice can kill the caster, even when the same spell defeats the rival.
	if hp <= 0:
		state = "resolving"
		pending_outcome = "dead"
		arena.player_defeated = true
		arena.opponent_defeated = enemy_hp <= 0
		drawing = false
		build_buttons()
		return
	if enemy_hp <= 0:
		last_reward = 35 + battle * 5 + (20 if battle % 5 == 0 else 0)
		coins += last_reward
		hp = mini(100, hp + 12)
		pending_outcome = "victory" if battle == Campaign.PLAYABLE_LEVELS else "shop"
		state = "resolving"
		arena.opponent_defeated = true
		battle += 1
		selected_slot = 0
		drawing = false
		build_buttons()

func enemy_spell_id() -> int:
	if encounter.has("spells"):
		return encounter.spells[attack_count % encounter.spells.size()]
	# Rivals use the same hand language for their visible spell effect.
	match encounter.pattern:
		"quick", "double": return 1
		"ward": return 4
		"elite": return 5 if next_damage() == 26 else 0
	return 0

func next_damage() -> int:
	if encounter.has("damages"):
		return encounter.damages[attack_count % encounter.damages.size()]
	if encounter.pattern == "elite" and attack_count % 2 == 1:
		return 26
	return encounter.damage

func next_interval() -> float:
	if encounter.pattern == "double" and attack_count % 2 == 1:
		return 0.8
	return encounter.interval * (0.7 if enraged else 1.0)

func prison_background() -> void:
	draw_texture_rect(UI.WALL, Rect2(0, 0, 480, 900), false)

func text(value: String, pos: Vector2, size := 20, color := Color("e9edf8")) -> void:
	UI.text(self, value, pos, size, color)

func panel(rect: Rect2, color := Color("1d263d")) -> void:
	draw_style_box(style(color), rect)

func style(color: Color) -> StyleBoxTexture:
	return UI.box(color.lightened(0.65))

func tableau(y: float) -> void:
	draw_texture_rect(preload("res://assets/pixel/cell_block.png"), Rect2(0, y, 480, 296), false)
	draw_texture_rect_region(preload("res://assets/pixel/apprentice.png"), Rect2(52, y + 104, 128, 144), Rect2(0, 0, 64, 72))
	draw_texture_rect_region(preload("res://assets/pixel/mazas.png"), Rect2(278, y + 12, 128, 144), Rect2(0, 0, 64, 72))

func glyph(id: int, origin: Vector2, size: float, color: Color) -> void:
	var points := PackedVector2Array()
	for point in Gestures.templates()[id]:
		points.append((origin + point * size).snapped(Vector2(2, 2)))
	draw_polyline(points, color, 4, false)
	draw_rect(Rect2(points[0] - Vector2(4, 4), Vector2(8, 8)), Color.WHITE)

func bar(rect: Rect2, ratio: float, color: Color) -> void:
	draw_rect(rect, Color("34495a"))
	if ratio > 0:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y)), color)

func _draw() -> void:
	prison_background()
	if state in ["menu", "tutorial", "intro", "intro_transition"]:
		return
	elif state in ["fight", "resolving"]:
		panel(Rect2(8, 8, 464, 82), Color("203341"))
		text("BLOQUE 01 / NIVEL %02d/15" % (arena.enemy_index + 1), Vector2(16, 32), 18, Color("b5ccbf"))
		text("%d monedas" % coins, Vector2(337, 32), 17, Color("e8ca8b"))
		text("APRENDIZ", Vector2(16, 60), 18)
		bar(Rect2(144, 46, 202, 12), hp / 100.0, Color("a1d4a8"))
		text("%d/100" % hp, Vector2(365, 58), 16)
		text("Barrera %d" % shield, Vector2(16, 83), 15, Color("94b6d2"))
		text("Tres runas / un solo trazo", Vector2(230, 83), 15, Color("889eaf"))
		for slot in 3:
			var id: int = equipped[slot]
			var x := 16 + slot * 154
			panel(Rect2(x, 98, 146, 94), Color("202e43"))
			glyph(id, Vector2(x + 13, 114), 37, COLORS[id] if cooldown[id] <= 0 else Color("65708b"))
			text(NAMES[id], Vector2(x + 59, 126), 16, COLORS[id])
			text("BLOQ." if paralyzed > 0 else ("Listo" if cooldown[id] <= 0 else "%.1f s" % cooldown[id]), Vector2(x + 59, 150), 15)
			bar(Rect2(x + 12, 174, 122, 5), 1 - cooldown[id] / COOLDOWNS[id], COLORS[id])
		# Arena and sprites are scene nodes; information overlays are in HUD.
		text(encounter.hint, Vector2(20, 518), 14, Color("bacbc7"))
		panel(DRAW_AREA, Color("19283c"))
		for x in range(40, 450, 20):
			for y in range(560, 785, 20):
				draw_rect(Rect2(x, y, 2, 2), Color("293b50"))
		text("TRAZA TU HECHIZO", Vector2(148, 553), 17, Color("a7b7be"))
		text("Empieza en el punto blanco del símbolo", Vector2(70, 778), 15, Color("879bad"))
		if stroke.size() > 1:
			var pixel_stroke := PackedVector2Array()
			for point in stroke:
				pixel_stroke.append(point.snapped(Vector2(2, 2)))
			draw_polyline(pixel_stroke, Color("c4dcff"), 4, false)
		if not stroke.is_empty():
			draw_rect(Rect2(stroke[0] - Vector2(3, 3), Vector2(6, 6)), Color.WHITE)
		panel(Rect2(16, 814, 448, 66), Color("1c2c40"))
		text(message, Vector2(25, 840), 14)
		text("PARÁLISIS: %.1f s" % paralyzed if paralyzed > 0 else ("Furia activa" if enraged else "Presos / Bloque de celdas"), Vector2(25, 864), 14, Color("93acaa"))
	elif state == "shop":
		panel(Rect2(16, 16, 448, 124))
		text("CONTRABANDO", Vector2(25, 52), 30, Color("a5c2ff"))
		text("Victoria: +%d monedas · +12 vida" % last_reward, Vector2(25, 90), 20)
		text("%d monedas · Vida %d · Próximo nivel %d/15" % [coins, hp, battle], Vector2(25, 121), 18, Color("ffdb77"))
		var shown := shop_items()
		for row in shown.size():
			var id: int = shown[row]
			var y := 258 + row * 148
			panel(Rect2(16, y, 448, 140), Color("263844"))
			glyph(id, Vector2(28, y + 18), 42, COLORS[id])
			text(NAMES[id], Vector2(84, y + 28), 16, COLORS[id])
			text(Book.QUALITY_NAMES[Book.QUALITY[id]], Vector2(84, y + 52), 16, Book.QUALITY_COLORS[Book.QUALITY[id]])
			text(DESCRIPTIONS[id] + " / %.1f s" % COOLDOWNS[id], Vector2(28, y + 88), 16)
			text(Book.RISKS[id], Vector2(28, y + 116), 16, Color("ed819e"))
		if shown.is_empty():
			text("YA POSEES TODAS LAS RUNAS", Vector2(60, 350), 16)
		text("ESPACIO SELECCIONADO: %d" % (selected_slot + 1), Vector2(30, 725), 16, Color("ffdb77"))
		text("3 OFERTAS NUEVAS TRAS CADA VICTORIA", Vector2(30, 840), 16, Color("a0aec9"))
		text("MIS RUNAS: EQUIPA LO QUE YA COMPRASTE", Vector2(30, 866), 16, Color("a0aec9"))
	else:
		panel(Rect2(24, 46, 432, 118))
		text("BLOQUE SUPERADO" if state == "victory" else "FUGA INTERRUMPIDA", Vector2(42, 104), 32, Color("edd5a0"))
		text("EL SÍNDICO HA CAÍDO" if state == "victory" else "TE DEVOLVIERON A LA CELDA", Vector2(44, 142), 16)
		tableau(186)
		panel(Rect2(28, 500, 424, 116))
		text("MONEDAS: %d" % coins, Vector2(48, 532), 16, Color("edd5a0"))
		text("ETAPA 1 COMPLETA / 15 NIVELES" if state == "victory" else "PRUEBA OTRA COMBINACIÓN DE RUNAS", Vector2(48, 560), 16)
		text("PRÓXIMAMENTE: PATIO Y TALLERES" if state == "victory" else "CADA INTENTO ES UNA NUEVA OPORTUNIDAD", Vector2(48, 588), 16)
