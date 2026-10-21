class_name PrisonCampaign
extends RefCounted

# Full campaign structure; only the first five authored encounters are playable.
const STAGES = ["Bloque de celdas", "Patio y talleres", "Complejo de seguridad", "Distrito penitenciario", "Umbral de salida"]
const LEVELS_PER_STAGE = 15
const PLAYABLE_LEVELS = 5
const OPENING = [
	{"name": "Cobrador del pasillo", "hp": 90, "damage": 12, "interval": 4.2, "pattern": "normal", "color": Color("d28a60"), "quote": "¿Inocente? Aquí todos dicen lo mismo.", "hint": "Pulso de chispas · protege tu vida."},
	{"name": "Chispa", "hp": 105, "damage": 9, "interval": 3.0, "pattern": "quick", "color": Color("e9be69"), "quote": "El pasillo no es gratis, aprendiz.", "hint": "Ataques rápidos · el hielo te da tiempo."},
	{"name": "La Remendadora", "hp": 120, "damage": 14, "interval": 4.4, "pattern": "ward", "color": Color("a4bfa7"), "quote": "Nadie cruza sin permiso del bloque.", "hint": "Barrera: absorbe los primeros 20 de daño."},
	{"name": "Tiza", "hp": 125, "damage": 8, "interval": 3.8, "pattern": "double", "color": Color("ba9ee5"), "quote": "Mis marcas llegan antes que tus dibujos.", "hint": "Dos pulsos seguidos · prepara el escudo."},
	{"name": "Mazas, dueño del corredor", "hp": 210, "damage": 16, "interval": 4.0, "pattern": "elite", "color": Color("e7876b"), "quote": "La puerta del patio la abro yo.", "hint": "Cada segundo golpe carga 26 de daño."}
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
