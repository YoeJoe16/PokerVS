extends SceneTree

const Campaign = preload("res://scripts/campaign.gd")
const Gestures = preload("res://scripts/gestures.gd")
var checks := 0
var failures := 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func _initialize() -> void:
	call_deferred("run")

func finish_visuals(scene: Node) -> void:
	for step in 40:
		if not scene.arena.is_busy():
			break
		scene.arena.advance(1.0)
	scene._process(0.0)

func run() -> void:
	var hero := preload("res://assets/pixel/apprentice.png").get_image()
	# In a back view, casting forearms must never paint over the jacket patch.
	for frame in range(2, 9):
		var patch_preserved := true
		for x in range(28, 39):
			for y in range(34, 44):
				patch_preserved = patch_preserved and hero.get_pixel(frame * 64 + x, y) == hero.get_pixel(x, y)
		check(patch_preserved, "Back view occludes casting arms in frame %d" % frame)
	var pixel_font = preload("res://assets/pixel/rune_font.fnt")
	for character in "áéíóúüñÁÉÍÓÚÜÑ¡¿":
		check(pixel_font.has_char(character.unicode_at(0)), "Pixel font supports " + character)
	var patterns := Gestures.templates()
	for id in SpellBook.NAMES.size():
		var transformed: Array = []
		for point in patterns[id]:
			transformed.append(point * 130 + Vector2(70, 530))
		check(Gestures.recognize(transformed, range(SpellBook.NAMES.size())) == id, "Recognizes translated/scaled spell %d" % id)
	check(Gestures.recognize([], [0, 1, 2]) == -1, "Empty gesture rejected")
	check(Gestures.recognize([Vector2.ZERO, Vector2.ZERO], [0, 1, 2]) == -1, "Stationary gesture rejected")
	check(Gestures.recognize(patterns[3], [0, 1, 2]) == -1, "Unequipped healing gesture rejected")
	for index in range(1, 76):
		var location := Campaign.location(index)
		check(location.faction == ("presos" if index <= 30 else "guardias"), "Faction at level %d" % index)
		var level: int = location.level
		check(location.rank == ("jefe" if level == 15 else ("élite" if level % 5 == 0 else "normal")), "Encounter rank at level %d" % index)
	check(Campaign.location(16).stage == 2 and Campaign.location(16).level == 1, "Stage transition after level 15")
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	scene.arena.set_process(false)
	var cell = scene.menu_cell
	cell.set_process(false)
	check(cell.visible and cell.playing and scene.controls.size() == 2, "Menu starts animated with two buttons")
	check(scene.controls[0].position.x < 100 and scene.controls[1].position.x > 300, "Tutorial and Start occupy opposite bottom corners")
	cell.elapsed = 0.0
	cell.advance(2.0)
	check(cell.look_direction() == -1 and cell.body.frame == 2, "Head looks left while body breathes")
	cell.advance(3.5)
	check(cell.look_direction() == 1 and cell.head.frame == 4, "Head turns right independently")
	var pose: Vector2 = cell.head.position
	cell.advance(12.0)
	check(is_equal_approx(cell.elapsed, 5.5) and cell.head.position == pose, "Full menu loop returns to identical pose")
	check(MenuCell.drop_state(0, 0.1).kind == "forming", "Leak forms a drop")
	check(MenuCell.drop_state(0, 1.0).kind == "falling", "Drop falls toward floor")
	check(MenuCell.drop_state(0, 1.6).kind == "splash", "Drop splashes on floor")
	for index in 3:
		var before = MenuCell.drop_state(index, 5.5)
		var after = MenuCell.drop_state(index, 17.5)
		check(before.kind == after.kind and before.position == after.position and is_equal_approx(before.progress, after.progress), "Leak loops seamlessly %d" % index)
	scene.controls[0].pressed.emit()
	check(scene.state == "tutorial" and scene.controls[1].disabled, "Tutorial opens with previous disabled")
	scene.controls[2].pressed.emit()
	check(scene.tutorial_page == 1, "Next tutorial page button works")
	scene.controls[1].pressed.emit()
	check(scene.tutorial_page == 0, "Previous tutorial page button works")
	scene.controls[0].pressed.emit()
	check(scene.state == "menu" and is_equal_approx(cell.elapsed, 5.5), "Closing tutorial preserves animation time")
	scene.controls[1].pressed.emit()
	check(scene.state == "fight" and not cell.visible and not cell.playing, "Start button hides and stops menu")
	cell.advance(1.0)
	check(is_equal_approx(cell.elapsed, 5.5), "Menu clock stops during combat")
	scene.state = "menu"
	scene.build_buttons()
	scene.controls[0].pressed.emit()
	scene.controls[2].pressed.emit()
	scene.controls[2].pressed.emit()
	check(scene.tutorial_page == 2 and scene.controls[2].text == "INICIAR", "Last tutorial page offers Start")
	scene.controls[2].pressed.emit()
	check(scene.state == "fight" and not cell.playing, "Start from tutorial begins a run")
	await process_frame
	check(scene.state == "fight" and scene.hp == 100, "New run starts fight")
	# Exercise the actual drawing input path, not just direct spell calls.
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(100, 700)
	scene._input(press)
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(250, 550)
	scene._input(motion)
	press.pressed = false
	press.position = motion.position
	scene._input(press)
	check(scene.enemy_hp == scene.enemy_max - 28, "Draw and release launches fire")
	var previous: int = scene.enemy_hp
	scene.cast_spell(0)
	check(scene.enemy_hp == previous, "Cooldown prevents duplicate cast")
	scene.cast_spell(2)
	scene.attack_timer = 0
	scene._process(0.01)
	check(scene.hp == 100 and scene.shield == 12, "Shield absorbs enemy attack")
	scene.shield = 0
	scene.attack_timer = 0
	scene._process(0.01)
	check(scene.hp == 88, "Enemy damages player")
	while scene.state == "fight":
		scene.cooldown.fill(0.0)
		scene.cast_spell(1)
	check(scene.state == "resolving" and scene.arena.visible, "Killing spell stays visible until its animation finishes")
	finish_visuals(scene)
	await process_frame
	check(scene.state == "shop" and scene.coins == 40 and scene.battle == 2, "Victory grants coins and opens shop")
	scene.shop_offers = [4, 5, 6]
	scene.coins = 60
	scene.select_spell(4)
	check(scene.coins == 5 and 4 in scene.owned and scene.equipped[0] == 4, "Purchase equips ice in selected slot")
	scene.select_spell(5)
	check(5 not in scene.owned and scene.coins == 5, "Cannot buy without enough coins")
	scene.select_spell(1)
	check(scene.equipped == [1, 4, 2], "Equipped spells swap without duplication")
	scene.start_battle()
	scene.cast_spell(4)
	var timer: float = scene.attack_timer
	scene._process(0.5)
	check(scene.attack_timer == timer, "Ice pauses enemy attacks")
	scene.owned.append(3)
	scene.selected_slot = 2
	scene.state = "shop"
	scene.select_spell(3)
	scene.state = "fight"
	scene.hp = 50
	scene.cast_spell(3)
	check(scene.hp == 76, "Healing restores health")
	scene.owned.append(5)
	scene.state = "shop"
	scene.select_spell(5)
	scene.state = "fight"
	scene.cast_spell(5)
	check(scene.cooldown[5] > 0, "Explosion starts cooldown")
	for step in 300:
		if scene.state == "victory":
			break
		if scene.state == "shop":
			scene.start_battle()
		scene.cooldown.fill(0.0)
		scene.cast_spell(1)
		finish_visuals(scene)
	await process_frame
	check(scene.battle == 16 and scene.state == "victory", "Fifteen victories complete first stage")
	scene.battle = 3
	scene.start_battle()
	scene.equipped = [0, 1, 2]
	scene.cast_spell(0)
	check(scene.enemy_hp == scene.enemy_max - 8 and scene.enemy_ward == 0, "Prisoner ward absorbs damage before health")
	scene.battle = 4
	scene.start_battle()
	scene.attack_timer = 0
	scene._process(0.01)
	check(is_equal_approx(scene.attack_timer, 0.8), "Double pulse schedules quick second hit")
	scene.attack_timer = 0
	scene._process(0.01)
	check(is_equal_approx(scene.attack_timer, 3.8), "Double pulse returns to normal interval")
	scene.battle = 5
	scene.start_battle()
	check(scene.next_damage() == 16, "Elite begins with normal attack")
	scene.attack_count = 1
	check(scene.next_damage() == 26, "Elite telegraphs charged second attack")
	scene.enemy_hp = 110
	scene.cast_spell(0)
	check(scene.enraged and scene.attack_timer <= 2.5, "Elite enrages at half health")
	check(is_equal_approx(scene.next_interval(), 2.8), "Enrage accelerates elite attacks")
	scene.enemy_hp = 1
	scene.cooldown.fill(0.0)
	scene.cast_spell(0)
	finish_visuals(scene)
	check(scene.last_reward == 80 and scene.state == "shop" and scene.battle == 6, "First elite pays bonus and opens level six")
	for level in range(6, 16):
		scene.battle = level
		scene.start_battle()
		check(scene.arena.enemy_index == level - 1 and scene.arena.opponent.texture == BattleArena.ENEMIES[level - 1], "Correct enemy sprite at level %d" % level)
		check(scene.enemy_hp == Campaign.encounter(level).hp, "Authored health at level %d" % level)
	for level in [9, 14]:
		scene.battle = level
		scene.start_battle()
		scene.enemy_hp -= 50
		scene.attack_count = 2
		scene.attack_timer = 0
		var health: int = scene.hp
		scene._process(0.01)
		check(scene.enemy_hp == scene.enemy_max - 26 and scene.hp == health and scene.arena.enemy_spell == 3, "Healer restores health instead of damaging player %d" % level)
	scene.battle = 10
	scene.start_battle()
	scene.attack_count = 1
	check(scene.next_damage() == 30 and scene.enemy_spell_id() == 5, "Second elite telegraphs charged explosion")
	scene.enemy_hp = 140
	scene.cast_spell(0)
	check(scene.enraged, "Second elite enrages")
	scene.battle = 15
	scene.start_battle()
	scene.attack_count = 1
	scene.attack_timer = 0
	var health: int = scene.hp
	scene._process(0.01)
	check(scene.enemy_ward == 24 and scene.hp == health and scene.arena.enemy_spell == 2, "Boss spends a turn raising a barrier")
	scene.attack_count = 3
	check(scene.next_damage() == 32 and scene.enemy_spell_id() == 5, "Boss cycle finishes with explosion")
	scene.enemy_ward = 0
	scene.enemy_hp = 215
	scene.cast_spell(0)
	check(scene.enraged and is_equal_approx(scene.next_interval(), 2.8), "Boss second phase accelerates cycle")
	scene.enemy_hp = 1
	scene.cooldown.fill(0.0)
	scene.cast_spell(0)
	check(scene.state == "resolving", "Boss defeat waits for final gesture")
	finish_visuals(scene)
	check(scene.state == "victory" and scene.battle == 16 and scene.last_reward == 130, "Boss ends stage and awards bonus")
	for id in 6:
		scene.new_run()
		scene.equipped = [id, (id + 1) % 6, (id + 2) % 6]
		scene.hp = 60
		scene.cast_spell(id)
		check(scene.arena.player_spell == id and scene.arena.player.frame == 2, "Spell %d begins gathering pose" % id)
		scene.arena.advance(0.25)
		check(scene.arena.player.frame == id + 3, "Spell %d has its own hand pose" % id)
		var queue_size: int = scene.arena.player_queue.size()
		scene.cast_spell(id)
		check(scene.arena.player_queue.size() == queue_size, "Rejected cooldown does not animate %d" % id)
		finish_visuals(scene)
		check(scene.arena.player.frame in [0, 1], "Spell %d returns to idle" % id)
	scene.new_run()
	scene.cast_spell(0)
	scene.cast_spell(2)
	check(scene.arena.player_queue == [2], "Rapid valid spells retain both gestures")
	scene.arena.advance(1.0)
	check(scene.arena.player_spell == 2, "Queued shield gesture plays after fire")
	finish_visuals(scene)
	scene.attack_timer = 0.0
	scene._process(0.01)
	scene.arena.advance(0.25)
	check(scene.arena.opponent.frame == 3, "Enemy fire attack uses fire hand pose")
	scene.new_run()
	check(not scene.arena.is_busy(), "Restart clears all pending animations")
	scene.new_run()
	check(scene.coins == 0 and scene.owned == [0, 1, 2], "Restart resets run progression")
	scene.hp = 1
	scene.attack_timer = 0
	scene._process(0.1)
	finish_visuals(scene)
	check(scene.state == "dead", "Lethal enemy attack ends run")
	await process_frame
	scene.queue_free()
	await process_frame
	print("SMOKE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
