class_name SpellGestures
extends RefCounted

const SAMPLES = 32

static func templates() -> Array:
	return [
		[Vector2(0, 1), Vector2(1, 0)],
		[Vector2(0.8, 0), Vector2(0.2, 0.45), Vector2(0.8, 0.55), Vector2(0.2, 1)],
		[Vector2(0.5, 0), Vector2(0.85, 0.15), Vector2(1, 0.5), Vector2(0.85, 0.85), Vector2(0.5, 1), Vector2(0.15, 0.85), Vector2(0, 0.5), Vector2(0.15, 0.15), Vector2(0.5, 0)],
		[Vector2(0, 0), Vector2(0.5, 1), Vector2(1, 0)],
		[Vector2(0, 1), Vector2(0.5, 0), Vector2(1, 1)],
		[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)],
		[Vector2(0, 1), Vector2(0.5, 0), Vector2(1, 1), Vector2(0, 1)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)],
		[Vector2(0, 1), Vector2(0, 0), Vector2(0.5, 0.65), Vector2(1, 0), Vector2(1, 1)],
		[Vector2(0, 0), Vector2(1, 0.5), Vector2(0, 1)],
		[Vector2(0, 0), Vector2(0.25, 1), Vector2(0.5, 0.25), Vector2(0.75, 1), Vector2(1, 0)],
		[Vector2(0, 1), Vector2(0, 0), Vector2(1, 1), Vector2(1, 0)],
		[Vector2(0.5, 0), Vector2(1, 0.5), Vector2(0.5, 1), Vector2(0, 0.5), Vector2(0.5, 0)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(0, 0)],
		[Vector2(0.5, 0), Vector2(0.8, 1), Vector2(0, 0.4), Vector2(1, 0.4), Vector2(0.2, 1), Vector2(0.5, 0)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(0, 0.3), Vector2(0.65, 0.3), Vector2(0.65, 0.7), Vector2(0.35, 0.7)]
	]

static func normalize(points: Array) -> Array:
	var length := 0.0
	for i in range(1, points.size()):
		length += points[i - 1].distance_to(points[i])
	if length < 0.001:
		return []
	var result: Array = [points[0]]
	var segment := 1
	var walked := 0.0
	for sample in range(1, SAMPLES):
		var target := length * sample / (SAMPLES - 1.0)
		while segment < points.size() - 1 and walked + points[segment - 1].distance_to(points[segment]) < target:
			walked += points[segment - 1].distance_to(points[segment])
			segment += 1
		var distance: float = points[segment - 1].distance_to(points[segment])
		result.append(points[segment - 1].lerp(points[segment], clampf((target - walked) / maxf(distance, 0.001), 0, 1)))
	var low: Vector2 = result[0]
	var high := low
	for point in result:
		low = low.min(point)
		high = high.max(point)
	var size := maxf((high - low).x, (high - low).y)
	var center := (low + high) / 2.0
	for i in result.size():
		result[i] = (result[i] - center) / maxf(size, 0.001)
	return result

static func recognize(points: Array, equipped: Array) -> int:
	var normalized := normalize(points)
	if normalized.is_empty():
		return -1
	var best := 0.23
	var found := -1
	var patterns := templates()
	for id in equipped:
		var reference := normalize(patterns[id])
		var score := 0.0
		for i in SAMPLES:
			score += normalized[i].distance_to(reference[i]) / SAMPLES
		if score < best:
			best = score
			found = id
	return found
