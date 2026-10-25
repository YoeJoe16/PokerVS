class_name IntroPanel
extends Node2D

# All scenery is drawn on the same 240-pixel grid and palette as menu_cell.
# Characters reuse the actual apprentice sprite and menu head, not illustrations.
const HERO = preload("res://assets/pixel/apprentice.png")
const HEAD = preload("res://assets/pixel/menu_head.png")
const INK = Color("111a2b")
var page := 0
var panel := 0
var clock := 0.0

func box(x: float, y: float, w: float, h: float, color: String) -> void:
	draw_rect(Rect2(roundf(x), roundf(y), w, h), Color(color))

func line(points: Array, color: String, width := 1.0) -> void:
	var snapped := PackedVector2Array()
	for point in points:
		snapped.append(Vector2(point).round())
	draw_polyline(snapped, Color(color), width, false)

func city() -> void:
	box(0, 0, 240, 230, "182332")
	box(176, 14, 18, 18, "b4b69a")
	box(184, 10, 15, 18, "182332")
	for i in 9:
		var x := i * 29 - 8
		var y := 28 + (i * 17) % 43
		box(x, y, 25, 106, "293846")
		box(x, y, 3, 106, "3b5358")
		for row in 5:
			for column in 2:
				if (i + row + column) % 3 != 0:
					box(x + 7 + column * 9, y + 7 + row * 13, 3, 5, "87988c")
	# A single magical neon sign identifies this as a modern magical city.
	line([Vector2(154, 47), Vector2(162, 59), Vector2(154, 71), Vector2(146, 59), Vector2(154, 47)], "82c5b4", 2)
	box(0, 117, 240, 110, "253641")
	line([Vector2(0, 118), Vector2(240, 118)], "536c69", 2)
	for y in [137, 164, 199]:
		box(0, y, 240, 1, "172a38")
	for x in [18, 88, 158, 218]:
		line([Vector2(120, 118), Vector2(x, 220)], "172a38")
	box(183, 98, 4, 40, "111a2b")
	box(175, 96, 20, 3, "bdbaa0")

func alley() -> void:
	# One vanishing point; paving and side walls share the same ground edges.
	box(0, 0, 240, 240, "182332")
	box(91, 12, 58, 70, "293846")
	for x in [99, 119, 139]:
		for y in [23, 44, 65]:
			box(x, y, 4, 6, "87988c")
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(83, 0), Vector2(83, 81), Vector2(0, 185)]), Color("293846"))
	draw_colored_polygon(PackedVector2Array([Vector2(157, 0), Vector2(240, 0), Vector2(240, 185), Vector2(157, 81)]), Color("263b40"))
	for y in [18, 49, 80, 111, 142]:
		line([Vector2(0, y), Vector2(83, 33 + y * 0.25)], "1f2d3b")
		line([Vector2(240, y), Vector2(157, 33 + y * 0.25)], "1f2d3b")
	line([Vector2(17, 0), Vector2(17, 149)], "637870", 3)
	# A doorway attached to the left wall, with a sloped lintel and threshold.
	draw_colored_polygon(PackedVector2Array([Vector2(30, 37), Vector2(57, 43), Vector2(57, 114), Vector2(30, 148)]), Color("14222e"))
	line([Vector2(32, 145), Vector2(32, 40), Vector2(56, 45)], "536c69", 2)
	box(49, 85, 3, 5, "bdbaa0")
	box(197, 26, 4, 52, "14222e")
	box(190, 23, 18, 4, "bdbaa0")
	var floor_shape := PackedVector2Array([Vector2(83, 81), Vector2(157, 81), Vector2(240, 185), Vector2(240, 240), Vector2(0, 240), Vector2(0, 185)])
	draw_colored_polygon(floor_shape, Color("253641"))
	line([Vector2(0, 185), Vector2(83, 81), Vector2(157, 81), Vector2(240, 185)], "536c69", 2)
	for y in [92, 110, 139, 178, 226]:
		var inset := maxf(0, 83 - (y - 81) * 83.0 / 104)
		line([Vector2(inset, y), Vector2(240 - inset, y)], "172a38")
	for x in [42, 94, 146, 198]:
		line([Vector2(120 + (x - 120) * 0.2, 81), Vector2(x, 240)], "172a38")
	box(149, 139, 21, 2, "435d66")
	box(43, 192, 28, 2, "435d66")

func bar_interior() -> void:
	# A modest modern bar: sign, bottles, counter, stools and tiled floor.
	box(0, 0, 240, 240, "293846")
	box(0, 80, 240, 160, "253641")
	box(0, 80, 240, 2, "536c69")
	box(86, 3, 68, 21, "14222e")
	box(88, 5, 64, 1, "82c5b4")
	draw_string(PixelUI.FONT, Vector2(108, 18), "BAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("82c5b4"))
	for x in [12, 160]:
		box(x, 13, 66, 45, "14222e")
		for y in [30, 52]:
			box(x + 2, y, 62, 3, "87988c")
			for offset in [8, 23, 40, 53]:
				box(x + offset, y - 12, 5, 11, "637870")
				box(x + offset + 1, y - 16, 3, 5, "87988c")
		box(x - 2, 59, 70, 7, "87988c")
		box(x, 66, 66, 20, "536c69")
		box(x + 3, 68, 60, 2, "bdbaa0")
	for x in [27, 191]:
		box(x, 84, 17, 4, "ba7454")
		box(x + 7, 88, 3, 17, "111a2b")
		box(x + 2, 104, 13, 2, "677c79")
	for y in [111, 145, 187, 231]:
		box(0, y, 240, 1, "172a38")
	for x in [39, 93, 147, 201]:
		line([Vector2(120 + (x - 120) * 0.4, 81), Vector2(x, 240)], "172a38")

func wall() -> void:
	box(0, 0, 240, 240, "293846")
	for y in range(0, 240, 19):
		box(0, y, 240, 1, "1f2d3b")
		for x in range((y / 19 as int) % 2 * 23 - 23, 240, 46):
			box(x, y, 1, 19, "1f2d3b")
	box(0, 170, 240, 70, "253641")
	box(0, 170, 240, 2, "536c69")
	line([Vector2(218, 0), Vector2(218, 146), Vector2(232, 146)], "637870", 3)

func hero_back(position: Vector2, frame := 0) -> void:
	draw_texture_rect_region(HERO, Rect2(position.round() - Vector2(32, 68), Vector2(64, 72)), Rect2(frame * 64, 0, 64, 72))

func hero_front(position: Vector2, zoom := 1.0, defeated := false, surprised := false, slumped := false) -> void:
	draw_set_transform(position.round(), 0, Vector2(zoom, zoom))
	if slumped:
		# Bent knees, spread feet and a lowered head make defeat unmistakable.
		line([Vector2(-5, -12), Vector2(-18, -9), Vector2(-21, 0)], "111a2b", 9)
		line([Vector2(-5, -12), Vector2(-18, -9), Vector2(-21, 0)], "35495b", 6)
		line([Vector2(5, -12), Vector2(17, -8), Vector2(23, 0)], "465a6a", 7)
		box(-25, -3, 10, 4, "111a2b")
		box(19, -3, 10, 4, "111a2b")
		box(-13, -29, 26, 19, "111a2b")
		box(-11, -27, 22, 16, "ba7454")
		box(-10, -26, 4, 13, "80514f")
		box(-1, -25, 2, 13, "e5aa75")
		line([Vector2(-12, -26), Vector2(-17, -17), Vector2(-16, -8)], "ba7454", 5)
		line([Vector2(12, -26), Vector2(16, -17), Vector2(18, -7)], "ba7454", 5)
		box(-18, -10, 5, 5, "cca68b")
		box(16, -9, 5, 5, "cca68b")
		box(-11, -30, 23, 6, "32797e")
		draw_texture_rect_region(HEAD, Rect2(-19, -57, 32, 32), Rect2(96, 0, 32, 32))
		draw_set_transform(Vector2.ZERO)
		return
	box(-10, -21, 7, 21, "35495b")
	box(3, -21, 7, 21, "465a6a")
	box(-12, -4, 10, 4, "111a2b")
	box(3, -4, 10, 4, "111a2b")
	box(-13, -39, 26, 25, "111a2b")
	box(-11, -37, 22, 22, "ba7454")
	box(-10, -36, 4, 20, "80514f")
	box(-1, -35, 2, 18, "e5aa75")
	box(4, -33, 5, 3, "e3cea0")
	box(-16, -34, 5, 19, "ba7454")
	box(11, -34, 5, 19, "ba7454")
	box(-16, -17, 5, 6, "cca68b")
	box(11, -17, 5, 6, "cca68b")
	box(-10, -40, 22, 6, "32797e")
	box(-8, -39, 17, 2, "82c5b4")
	var frame := 3 if defeated else 2
	draw_texture_rect_region(HEAD, Rect2(-16, -69, 32, 32), Rect2(frame * 32, 0, 32, 32))
	if surprised:
		box(-5, -51, 3, 3, "e4d4b4")
		box(3, -51, 3, 3, "e4d4b4")
		box(-4, -50, 1, 2, "172735")
		box(4, -50, 1, 2, "172735")
		box(-2, -45, 4, 3, "354552")
	draw_set_transform(Vector2.ZERO)

func officer(position: Vector2, zoom := 1.0, casting := false, startled := false) -> void:
	draw_set_transform(position.round(), 0, Vector2(zoom, zoom))
	box(-10, -22, 7, 22, "26384b")
	box(3, -22, 7, 22, "35495b")
	box(-12, -4, 10, 4, "111a2b")
	box(3, -4, 10, 4, "111a2b")
	box(-14, -40, 28, 23, "111a2b")
	box(-12, -38, 24, 21, "35495b")
	box(-10, -36, 4, 17, "26384b")
	box(-1, -37, 2, 19, "677c79")
	box(5, -35, 4, 5, "bdbaa0")
	box(-13, -20, 26, 4, "111a2b")
	box(-2, -20, 4, 4, "87988c")
	if casting:
		line([Vector2(-12, -36), Vector2(-22, -45), Vector2(-24, -59)], "111a2b", 7)
		line([Vector2(-12, -36), Vector2(-22, -45), Vector2(-24, -59)], "35495b", 5)
		line([Vector2(12, -36), Vector2(22, -45), Vector2(24, -59)], "35495b", 5)
		box(-26, -63, 5, 7, "cca68b")
		box(22, -63, 5, 7, "cca68b")
	else:
		box(-17, -35, 5, 19, "35495b")
		box(12, -35, 5, 19, "35495b")
		box(-17, -18, 5, 6, "cca68b")
		box(12, -18, 5, 6, "cca68b")
	box(-10, -60, 20, 21, "111a2b")
	box(-8, -58, 16, 17, "cca68b")
	box(-8, -54, 3, 12, "8d6870")
	box(-5, -51, 3, 2, "172735")
	box(3, -51, 3, 2, "172735")
	box(-2, -45, 5, 1, "8d6870")
	box(-12, -65, 24, 8, "111a2b")
	box(-10, -64, 20, 5, "35495b")
	box(-12, -58, 25, 3, "677c79")
	box(-2, -63, 4, 4, "bdbaa0")
	if startled:
		box(20, -70, 3, 10, "e4d4b4")
		box(20, -57, 3, 3, "e4d4b4")
	draw_set_transform(Vector2.ZERO)

func curse(center: Vector2, size: float) -> void:
	var points := PackedVector2Array()
	for index in [0, 2, 4, 1, 3, 0]:
		var angle: float = -PI / 2 + TAU * index / 5.0
		points.append((center + Vector2(cos(angle), sin(angle)) * size).round())
	draw_polyline(points, Color("b78fea"), 2, false)

func _draw() -> void:
	match page * 3 + panel:
		0:
			city()
			hero_back(Vector2(49 + mini(8, int(clock * 3)), 150), int(clock * 2) % 2)
		1:
			alley()
			hero_back(Vector2(121, 120 + mini(12, int(clock * 4))), int(clock * 3) % 2)
		2:
			wall()
			hero_front(Vector2(96, 160), 2.0, false, true)
			box(154, 37, 5, 21, "e4d4b4")
			box(154, 64, 5, 5, "e4d4b4")
		3:
			bar_interior()
			# Unarmed civilian on the ground, no gore.
			box(88, 120, 57, 7, "142432")
			box(93, 112, 13, 10, "cca68b")
			box(91, 110, 7, 7, "354552")
			box(106, 114, 24, 10, "87988c")
			box(130, 116, 26, 6, "35495b")
			box(152, 115, 8, 8, "111a2b")
			officer(Vector2(76, 105))
			officer(Vector2(165, 111))
			curse(Vector2(61, 91), 6)
		4:
			bar_interior()
			officer(Vector2(64, 174), 2.0, false, true)
			officer(Vector2(181, 178), 2.0, false, true)
		5:
			bar_interior()
			officer(Vector2(139, 102))
			officer(Vector2(190, 112))
			hero_back(Vector2(51, 146), 3)
		6:
			bar_interior()
			officer(Vector2(121, 194), 2.0, true)
			for i in 5:
				curse(Vector2(51 + i * 35, 27 + (i % 2) * 12), 8 + int(clock * 3 + i) % 2)
		7:
			wall()
			line([Vector2(76, 36), Vector2(96, 60), Vector2(85, 76), Vector2(102, 91), Vector2(81, 119)], "111a2b", 2)
			line([Vector2(97, 65), Vector2(126, 53), Vector2(139, 61)], "111a2b", 2)
			# Two discrete pixel motions: impact against wall, then slump to floor.
			var fall := clampf((clock - 0.7) / 1.2, 0, 1)
			var x := 104 + (2 if clock < 0.7 and int(clock * 18) % 2 == 0 else 0)
			hero_front(Vector2(x, 144 + roundf(fall * 26)), 1.5, true, false, fall >= 0.8)
			if clock < 1.0:
				line([Vector2(236, 36), Vector2(169, 68), Vector2(188, 78), Vector2(113, 93)], "b78fea", 3)
			for i in 5:
				box(75 + i * 13, 156 + (i % 2) * 9, 4, 3, "677c79")
