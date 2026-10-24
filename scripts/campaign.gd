class_name PrisonCampaign
extends RefCounted

# Full campaign structure; the complete first stage is playable.
const STAGES = ["Bloque de celdas", "Patio y talleres", "Complejo de seguridad", "Distrito penitenciario", "Umbral de salida"]
const LEVELS_PER_STAGE = 15
const PLAYABLE_LEVELS = 15
const OPENING = [
	{"name": "Cobrador del pasillo", "hp": 90, "damage": 12, "interval": 4.2, "pattern": "normal", "color": Color("d28a60"), "quote": "¿Inocente? Aquí todos dicen lo mismo.", "hint": "Pulso de chispas · protege tu vida."},
	{"name": "Chispa", "hp": 105, "damage": 9, "interval": 3.0, "pattern": "quick", "color": Color("e9be69"), "quote": "El pasillo no es gratis, aprendiz.", "hint": "Ataques rápidos · el hielo te da tiempo."},
	{"name": "La Remendadora", "hp": 120, "damage": 14, "interval": 4.4, "pattern": "ward", "color": Color("a4bfa7"), "quote": "Nadie cruza sin permiso del bloque.", "hint": "Barrera: absorbe los primeros 20 de daño."},
	{"name": "Tiza", "hp": 125, "damage": 8, "interval": 3.8, "pattern": "double", "color": Color("ba9ee5"), "quote": "Mis marcas llegan antes que tus dibujos.", "hint": "Dos pulsos seguidos · prepara el escudo."},
	{"name": "Mazas, dueño del corredor", "hp": 210, "damage": 16, "interval": 4.0, "pattern": "elite", "color": Color("e7876b"), "quote": "Este corredor es mío.", "hint": "Cada segundo golpe carga 26 de daño."},
	{"name": "Brasa", "hp": 155, "damage": 15, "interval": 3.6, "pattern": "normal", "quote": "No toques mis cerillas.", "hint": "Fuego constante · alterna ataque y escudo.", "damages": [15], "spells": [0], "ward": 0},
	{"name": "La Aguja", "hp": 165, "damage": 10, "interval": 3.7, "pattern": "double", "quote": "Un hilo basta para cerrar el paso.", "hint": "Dos pulsos · protege ambos impactos.", "damages": [10], "spells": [1], "ward": 0},
	{"name": "Vaho", "hp": 180, "damage": 17, "interval": 4.1, "pattern": "ward", "quote": "Aquí hasta el aire tiene dueño.", "hint": "Barrera de 32 · rompe su defensa.", "damages": [17], "spells": [4], "ward": 32},
	{"name": "El Zurcidor", "hp": 190, "damage": 13, "interval": 4.0, "pattern": "mend", "quote": "Siempre queda algo que remendar.", "hint": "Cada tercer turno cura 24 de vida.", "damages": [13, 13, 0], "spells": [0, 0, 3], "ward": 0},
	{"name": "La Cerrajera", "hp": 285, "damage": 18, "interval": 3.8, "pattern": "elite", "quote": "Cada cerradura guarda una deuda.", "hint": "Alterna 18 y 30 · furia a media vida.", "damages": [18, 30], "spells": [1, 5], "ward": 0},
	{"name": "Ceniza", "hp": 220, "damage": 19, "interval": 3.6, "pattern": "normal", "quote": "Lo que arde deja una salida.", "hint": "Alterna fuego y explosión: 19 / 25.", "damages": [19, 25], "spells": [0, 5], "ward": 0},
	{"name": "Eco", "hp": 225, "damage": 12, "interval": 3.5, "pattern": "double", "quote": "Escucha el segundo golpe.", "hint": "Dos rayos de 12 · no bajes la guardia.", "damages": [12], "spells": [1], "ward": 0},
	{"name": "La Muralla", "hp": 250, "damage": 22, "interval": 4.5, "pattern": "ward", "quote": "No voy a apartarme.", "hint": "Barrera de 48 · golpes lentos y fuertes.", "damages": [22], "spells": [4], "ward": 48},
	{"name": "Sutura", "hp": 260, "damage": 17, "interval": 3.6, "pattern": "mend", "quote": "Todavía no hemos terminado.", "hint": "Dos ataques y una cura de 24.", "damages": [17, 17, 0], "spells": [1, 0, 3], "ward": 0},
	{"name": "El Síndico", "hp": 420, "damage": 18, "interval": 4.0, "pattern": "boss", "quote": "En este bloque, yo decido quién sale.", "hint": "Fuego, barrera, rayo, explosión.", "damages": [18, 0, 20, 32], "spells": [0, 2, 1, 5], "ward": 0}
]

static func location(index: int) -> Dictionary:
	assert(index >= 1 and index <= STAGES.size() * LEVELS_PER_STAGE)
	var stage := int((index - 1) / LEVELS_PER_STAGE)
	var level := (index - 1) % LEVELS_PER_STAGE + 1
	return {"stage": stage + 1, "title": STAGES[stage], "level": level,
		"faction": "presos" if stage < 2 else "guardias",
		"rank": "jefe" if level == 15 else ("élite" if level % 5 == 0 else "normal")}

static func encounter(index: int) -> Dictionary:
	assert(index >= 1 and index <= PLAYABLE_LEVELS)
	return OPENING[index - 1].duplicate()
