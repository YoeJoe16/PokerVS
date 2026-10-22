class_name BattleArena
extends Node2D

# Sprite sheet order: idle, breath, gather, six hand signs, hit, down.
const CAST_DURATION := 0.9
const IMPACT_TIME := 0.48
const SPELL_COLORS = [Color("ffa96a"), Color("ffe39a"), Color("85c4f2"), Color("9fe2ad"), Color("9ee9ef"), Color("caabef")]
const ENEMIES = [preload("res://assets/pixel/collector.png"), preload("res://assets/pixel/spark.png"), preload("res://assets/pixel/mender.png"), preload("res://assets/pixel/chalk.png"), preload("res://assets/pixel/mazas.png")]
@onready var player: Sprite2D = $Apprentice
@onready var opponent: Sprite2D = $Opponent
var player_queue: Array[int] = []
var enemy_queue: Array[int] = []
var player_spell := -1
var enemy_spell := -1
var player_elapsed := 0.0
var enemy_elapsed := 0.0
var clock := 0.0
var opponent_frozen := false
var opponent_defeated := false
var player_defeated := false
var player_barrier := false
var opponent_barrier := false
var enemy_index := 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func reset(index: int) -> void:
	enemy_index = clampi(index, 0, 4)
	opponent.texture = ENEMIES[enemy_index]
	player_queue.clear()
	enemy_queue.clear()
	player_spell = -1
	enemy_spell = -1
	player_elapsed = 0.0
	enemy_elapsed = 0.0
	opponent_defeated = false
	player_defeated = false
	opponent_frozen = false
	player_barrier = false
	opponent_barrier = false
	update_sprites()

func play_spell(id: int, from_player := true) -> void:
	assert(id >= 0 and id < 6)
	if from_player:
		player_queue.append(id)
	else:
		enemy_queue.append(id)
	advance(0.0)

func is_busy() -> bool:
	return player_spell >= 0 or enemy_spell >= 0 or not player_queue.is_empty() or not enemy_queue.is_empty()

func _process(delta: float) -> void:
	if visible:
		advance(delta)

func advance(delta: float) -> void:
	clock += delta
	if player_spell >= 0:
		player_elapsed += delta
		if player_elapsed >= CAST_DURATION:
			player_spell = -1
	if enemy_spell >= 0:
		enemy_elapsed += delta
		if enemy_elapsed >= CAST_DURATION:
			enemy_spell = -1
	if player_spell < 0 and not player_queue.is_empty():
		player_spell = player_queue.pop_front()
		player_elapsed = 0.0
	if enemy_spell < 0 and not enemy_queue.is_empty():
		enemy_spell = enemy_queue.pop_front()
		enemy_elapsed = 0.0
	update_sprites()
	queue_redraw()

func pose(spell: int, elapsed: float) -> int:
	if spell < 0:
		return int(clock * 2) % 2
	if elapsed < 0.16 or elapsed > 0.78:
		return 2
	return 3 + spell

func update_sprites() -> void:
	player.frame = pose(player_spell, player_elapsed)
	opponent.frame = pose(enemy_spell, enemy_elapsed)
	player.position = Vector2(114, 274)
	opponent.position = Vector2(344, 142)
	player.modulate = Color.WHITE
	opponent.modulate = Color("96cfe1") if opponent_frozen else Color.WHITE
	if player_spell >= 0 and player_elapsed >= IMPACT_TIME and player_spell in [0, 1, 4, 5]:
		if player_elapsed < 0.68:
			opponent.position.x += 2 if int(player_elapsed * 35) % 2 == 0 else -2
			opponent.modulate = Color("ffd4ad")
			if enemy_spell < 0:
				opponent.frame = 9
	if enemy_spell >= 0 and enemy_elapsed >= IMPACT_TIME and enemy_elapsed < 0.68:
		player.position.x += -2 if int(enemy_elapsed * 35) % 2 == 0 else 2
		player.modulate = Color("ffc7bc")
		if player_spell < 0:
			player.frame = 9
	if opponent_defeated and player_spell < 0 and player_queue.is_empty():
		opponent.frame = 10
	if player_defeated and enemy_spell < 0 and enemy_queue.is_empty():
		player.frame = 10

func pixel(point: Vector2, size: int, color: Color) -> void:
	draw_rect(Rect2(point.snapped(Vector2(2, 2)), Vector2(size, size)), color)

func ring(center: Vector2, radius: float, color: Color) -> void:
	for i in 28:
		var angle := TAU * i / 28.0
		pixel(center + Vector2(cos(angle), sin(angle)) * radius, 4, color)

func _draw() -> void:
	# This node draws effects after its sibling actor sprites (z_index = 2).
	if player_barrier:
		ring(player.position + Vector2(0, -34) * player.scale, 54, Color("668da8"))
	if opponent_barrier:
		ring(Vector2(344, 84), 42, Color("99b2ac"))
	if opponent_frozen:
		for x in [314, 330, 348, 364]:
			draw_colored_polygon(PackedVector2Array([Vector2(x, 143), Vector2(x + 4, 119), Vector2(x + 12, 143)]), Color("8bd6de"))
	if player_spell >= 0:
		effect(player_spell, player_elapsed, true)
	if enemy_spell >= 0:
		effect(enemy_spell, enemy_elapsed, false)

func hand_origin(id: int, from_player: bool) -> Vector2:
	var anchors := [Vector2(59, 27), Vector2(50, 4), Vector2(32, 30), Vector2(32, 30), Vector2(61, 32), Vector2(32, 18)]
	var anchor: Vector2 = anchors[id]
	if from_player and id == 3:
		anchor = Vector2(44, 23)
	if not from_player:
		anchor.x = 63 - anchor.x
	var actor: Sprite2D = player if from_player else opponent
	return actor.position + (anchor - Vector2(32, 68)) * actor.scale

func effect(id: int, elapsed: float, from_player: bool) -> void:
	var origin := hand_origin(id, from_player)
	var receiver: Sprite2D = opponent if from_player else player
	var sender: Sprite2D = player if from_player else opponent
	var target := receiver.position + Vector2(0, -34) * receiver.scale
	var caster := sender.position + Vector2(0, -34) * sender.scale
	var color: Color = SPELL_COLORS[id]
	var travel := clampf((elapsed - 0.24) / 0.24, 0, 1)
	if elapsed < 0.24:
		if elapsed < 0.16:
			origin = caster
		for i in 5:
			var angle := TAU * i / 5.0 + elapsed * 10
			pixel(origin + Vector2(cos(angle), sin(angle)) * (18 - elapsed * 40), 4, color)
		return
	match id:
		0:
			var point := origin.lerp(target, travel).snapped(Vector2(2, 2))
			if elapsed < 0.55:
				for i in range(5, -1, -1):
					var tail := point - (target - origin).normalized() * i * 5
					pixel(tail + Vector2(0, (i % 2) * 2), maxi(4, 14 - i * 2), Color("c65552"))
				pixel(point - Vector2(5, 5), 12, color)
				pixel(point - Vector2(2, 2), 6, Color("fff3bd"))
		1:
			if elapsed < 0.66:
				var points := PackedVector2Array([origin, origin.lerp(target, 0.3) + Vector2(8, 20), origin.lerp(target, 0.48) - Vector2(14, 12), origin.lerp(target, 0.72) + Vector2(16, 14), target])
				for i in points.size():
					points[i] = points[i].snapped(Vector2(2, 2))
				draw_polyline(points, Color("a97ab8"), 8, false)
				draw_polyline(points, color, 4, false)
		2:
			ring(caster, 34 + minf(12, elapsed * 15), color)
			var shield_points := PackedVector2Array([caster + Vector2(-26, -32), caster + Vector2(26, -32), caster + Vector2(26, 12), caster + Vector2(0, 34), caster + Vector2(-26, 12), caster + Vector2(-26, -32)])
			draw_polyline(shield_points, color, 4, false)
		3:
			for i in 5:
				var point := caster + Vector2(-30 + i * 14, 24 - fmod(elapsed * 60 + i * 13, 65))
				pixel(point - Vector2(4, 0), 12, color)
				draw_rect(Rect2((point + Vector2(0, -4)).snapped(Vector2(2, 2)), Vector2(4, 20)), color)
		4:
			for i in 3:
				var point := origin.lerp(target, clampf(travel - i * 0.12, 0, 1)).snapped(Vector2(2, 2))
				draw_colored_polygon(PackedVector2Array([point + Vector2(-12, 6), point + Vector2(8, -12), point + Vector2(10, 4)]), color)
				draw_line(point + Vector2(-8, 4), point + Vector2(8, -10), Color("e8ffff"), 2, false)
		5:
			var center := origin.lerp(target, travel)
			ring(center, 8 + travel * 20, color)
			if elapsed >= IMPACT_TIME:
				ring(target, 18 + (elapsed - IMPACT_TIME) * 80, Color("f0c9e5"))
	if elapsed >= IMPACT_TIME and id in [0, 1, 4, 5]:
		for i in 8:
			var angle := TAU * i / 8.0
			pixel(target + Vector2(cos(angle), sin(angle)) * (12 + (elapsed - IMPACT_TIME) * 90), 6 if id == 5 else 4, color)
