class_name SpellBook
extends RefCounted

const NAMES = ["Fuego", "Rayo", "Escudo", "Curación", "Hielo", "Explosión", "Roca", "Viento", "Brote", "Lanza", "Glaciar", "Trueno", "Égida", "Meteoro", "Sangre", "Vacío", "Reflejo"]
const DESCRIPTIONS = ["28 daño", "42 daño", "+24 barrera", "+26 vida", "16 daño / frena 2.5 s", "60 daño", "22 daño", "18 daño / frena 0.6 s", "+18 vida / +12 barrera", "60 daño / ignora barrera", "28 daño / frena 4 s", "90 daño", "+48 barrera / +20 vida", "140 daño", "220 daño", "180 daño", "Devuelve 1 ataque / 1.5 s"]
const RISKS = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "COSTE: 34 VIDA / PUEDE MATARTE", "COSTE: PARÁLISIS 3 S", "MÁX. 40 DAÑO / SE CONSUME AL USAR"]
const COLORS = [Color("ff9466"), Color("ffdb77"), Color("83b8ff"), Color("8de9b0"), Color("7be8ed"), Color("d7a0ff"), Color("bfa98b"), Color("b2e3d9"), Color("a9d679"), Color("dce3f0"), Color("83d5ed"), Color("d4b1ff"), Color("fff0b0"), Color("ffc17b"), Color("ed7595"), Color("b78fea"), Color("b7e5ef")]
const COOLDOWNS = [1.4, 2.8, 4.0, 6.0, 3.0, 5.0, 1.0, 1.8, 5.0, 4.0, 6.0, 6.0, 9.0, 9.0, 12.0, 10.0, 10.0]
const QUALITY = [0, 1, 0, 1, 1, 2, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 3]
const QUALITY_NAMES = ["COMÚN", "RARO", "ESPECIAL", "LEGENDARIO", "MAGIA NEGRA"]
const QUALITY_COLORS = [Color("becbbd"), Color("8dbdf5"), Color("c5a1ef"), Color("efce86"), Color("ed819e")]
const WEIGHTS = [60, 24, 10, 5, 1]
const PRICES = [35, 55, 85, 120, 150]
# The six hand families remain shared; every spell has its own rune and color.
const POSES = [0, 1, 2, 3, 4, 5, 0, 4, 3, 4, 4, 1, 2, 5, 5, 5, 2]
const DAMAGE = [28, 42, 0, 0, 16, 60, 22, 18, 0, 60, 28, 90, 0, 140, 220, 180, 0]

static func price(id: int) -> int:
	return PRICES[QUALITY[id]]

# Draw category first, then a uniform spell from its remaining candidates.
# Owned spells are excluded; exhausted categories are removed and weights normalized.
static func offers(owned: Array, rng: RandomNumberGenerator) -> Array:
	var result: Array = []
	for slot in 3:
		var pools: Array = [[], [], [], [], []]
		for id in NAMES.size():
			if id not in owned and id not in result:
				pools[QUALITY[id]].append(id)
		var total := 0
		for quality in 5:
			if not pools[quality].is_empty():
				total += WEIGHTS[quality]
		if total == 0:
			break
		var roll := rng.randi_range(1, total)
		for quality in 5:
			if pools[quality].is_empty():
				continue
			roll -= WEIGHTS[quality]
			if roll <= 0:
				result.append(pools[quality][rng.randi_range(0, pools[quality].size() - 1)])
				break
	return result
