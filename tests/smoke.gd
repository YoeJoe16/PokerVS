extends SceneTree

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

func run() -> void:
	var patterns := Gestures.templates()
	for id in 6:
		var transformed: Array = []
		for point in patterns[id]:
			transformed.append(point * 130 + Vector2(70, 530))
		check(Gestures.recognize(transformed, [0, 1, 2, 3, 4, 5]) == id, "Recognizes translated/scaled spell %d" % id)
	check(Gestures.recognize([], [0, 1, 2]) == -1, "Empty gesture rejected")
	check(Gestures.recognize([Vector2.ZERO, Vector2.ZERO], [0, 1, 2]) == -1, "Stationary gesture rejected")
	check(Gestures.recognize(patterns[3], [0, 1, 2]) == -1, "Unequipped healing gesture rejected")
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	scene.new_run()
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
	await process_frame
	check(scene.state == "shop" and scene.coins == 40 and scene.battle == 2, "Victory grants coins and opens shop")
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
	scene.select_spell(3)
	scene.hp = 50
	scene.cast_spell(3)
	check(scene.hp == 76, "Healing restores health")
	scene.owned.append(5)
	scene.select_spell(5)
	scene.cast_spell(5)
	check(scene.cooldown[5] > 0, "Explosion starts cooldown")
	while scene.state != "victory":
		if scene.state == "shop":
			scene.start_battle()
		scene.cooldown.fill(0.0)
		scene.cast_spell(1)
	await process_frame
	check(scene.battle == 6, "Five victories complete expedition")
	scene.new_run()
	check(scene.coins == 0 and scene.owned == [0, 1, 2], "Restart resets run progression")
	scene.hp = 1
	scene.attack_timer = 0
	scene._process(0.1)
	check(scene.state == "dead", "Lethal enemy attack ends run")
	await process_frame
	scene.queue_free()
	await process_frame
	print("SMOKE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
